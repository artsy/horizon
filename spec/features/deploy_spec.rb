# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Deploys', type: :feature do
  let(:org) { Organization.create!(name: 'artsy') }
  let(:project) { org.projects.create!(name: 'candela') }
  let(:stages) do
    (1..2).map do |i|
      project.stages.create!(
        name: "stage #{i}",
        git_remote: 'https://github.com/artsy/candela.git'
      )
    end
  end
  let(:profile) { org.profiles.create!(basic_password: 'foo') }
  let(:strategy) do
    stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: { base: 'release', head: 'staging', blocked_time_buckets: [] },
      profile: profile
    )
  end
  let(:renovate) { double('user', type: 'Bot', login: 'renovate') }
  let(:joe) { double('user', type: 'User', login: 'joe') }
  let(:jane) { double('user', type: 'User', login: 'jane') }
  let(:web_flow) { double('user', type: 'User', login: 'web-flow') }
  let(:commits) do
    [
      double('commit', author: renovate, committer: renovate),
      double('commit', author)
    ]
  end
  let(:github_pull_request) { double(number: 42, assignee: nil, created_at: 25.hours.ago) }
  let(:assigned_github_pull_request) do
    double(
      number: 42,
      assignee: 'jane',
      created_at: 25.hours.ago,
      html_url: 'https://github.com/artsy/candela/pull/342',
      mergeable?: true
    )
  end

  it 'raises error unless profile.basic_password is present' do
    invalid_strategy = stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: { base: 'release', head: 'staging' }
    )
    expect do
      DeployService.new(invalid_strategy).start
    end.to raise_error('A profile and basic_password are required for Github authentication')
  end

  it 'sends an Octokit request to create pull request' do
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_return(github_pull_request)
    allow_any_instance_of(Octokit::Client).to receive(:pull_request_commits).and_return([])
    DeployService.new(strategy).start
  end

  it 'assigns deploy pull request to appropriate user' do
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_return(github_pull_request)
    allow_any_instance_of(Octokit::Client).to receive(:pull_request_commits)
      .with('artsy/candela', 42)
      .and_return([
                    double(author: renovate, committer: renovate),
                    double(author: joe, committer: jane),
                    double(author: jane, committer: web_flow),
                    double(author: renovate, committer: jane)
                  ])
    expect_any_instance_of(Octokit::Client).to receive(:check_assignee).and_return(true)
    expect_any_instance_of(Octokit::Client).to receive(:add_assignees).with('artsy/candela', 42, 'jane')
    DeployService.new(strategy).start
  end

  it 'handles unsigned commits' do
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_return(github_pull_request)
    allow_any_instance_of(Octokit::Client).to receive(:pull_request_commits)
      .with('artsy/candela', 42)
      .and_return([
                    double(author: nil, committer: renovate),
                    double(author: jane, committer: web_flow)
                  ])
    expect_any_instance_of(Octokit::Client).to receive(:check_assignee).and_return(true)
    expect_any_instance_of(Octokit::Client).to receive(:add_assignees).with('artsy/candela', 42, 'jane')
    DeployService.new(strategy).start
  end

  it 'adds assignees to existing deploy PRs when unassigned' do
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([github_pull_request])
    allow_any_instance_of(Octokit::Client).to receive(:pull_request_commits)
      .with('artsy/candela', 42)
      .and_return([
                    double(author: renovate, committer: renovate),
                    double(author: joe, committer: jane),
                    double(author: jane, committer: web_flow),
                    double(author: renovate, committer: jane)
                  ])
    expect_any_instance_of(Octokit::Client).to receive(:check_assignee).and_return(true)
    expect_any_instance_of(Octokit::Client).to receive(:add_assignees).with('artsy/candela', 42, 'jane')

    DeployService.new(strategy).start
  end

  it 'merges release PR after designated period of time' do
    strategy.update!(arguments: strategy.arguments.merge(merge_after: 24.hours.to_i))
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    allow_any_instance_of(Octokit::Client).to receive(:pull_request)
      .with('artsy/candela', 42)
      .and_return(assigned_github_pull_request)
    expect_any_instance_of(Octokit::Client).to receive(:merge_pull_request).with('artsy/candela', 42)

    DeployService.new(strategy).start
  end

  it 'does not attempt to merge unmergeable PRs' do
    strategy.update!(arguments: strategy.arguments.merge(merge_after: 24.hours.to_i))
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    allow_any_instance_of(Octokit::Client).to receive(:pull_request)
      .with('artsy/candela', 42)
      .and_return(assigned_github_pull_request)
    expect(assigned_github_pull_request).to receive(:mergeable?).and_return(false)
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)

    DeployService.new(strategy).start
  end

  it 'notifies one Slack prior to automatically merging release PR' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: ['https://hooks.slack.com/services/foo/bar/baz']
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)
    strategy.arguments['slack_webhook_url'].each do |webhook_url|
      webhook = stub_request(:post, webhook_url.strip).with(
        body: {
          text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).to_return(status: 201)
      DeployService.new(strategy).start
      # notification not repeated
      DeployService.new(strategy).start
      expect(webhook).to have_been_made.once
    end
  end

  it 'notifies one Slack prior to automatically merging release PR, backwards String based config compatible' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: 'https://hooks.slack.com/services/foo/bar/baz'
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)

    webhook = stub_request(:post, strategy.arguments['slack_webhook_url'].strip).with(
      body: {
        text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(status: 201)
    DeployService.new(strategy).start
    # notification not repeated
    DeployService.new(strategy).start
    expect(webhook).to have_been_made.once
  end

  it 'notifies multiple Slack prior to automatically merging release PR' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: ['https://hooks.slack.com/services/foo/bar/baz', 'https://hooks.slack.com/services/foo/bar/azb']
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)

    webhook = stub_request(:post, strategy.arguments['slack_webhook_url'].first.strip).with(
      body: {
        text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(status: 201)

    secondwebhook = stub_request(:post, strategy.arguments['slack_webhook_url'].second.strip).with(
      body: {
        text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(status: 201)

    DeployService.new(strategy).start
    # notification not repeated
    DeployService.new(strategy).start
    expect(webhook).to have_been_made.once
    expect(secondwebhook).to have_been_made.once
  end

  it 'fails to notifies one Slack prior to automatically merging release PR due invalid non String||Array attr' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: 100
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)

    webhook = stub_request(:post, strategy.arguments['slack_webhook_url'].to_s).with(
      body: {
        text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    ).to_return(status: 201)
    DeployService.new(strategy).start
    # notification not repeated
    DeployService.new(strategy).start
    expect(webhook).not_to have_been_made
  end

  it 'fails to notifies one Slack prior to automatically merging release PR due invalid protocol' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: ['http://hooks.slack.com/services/foo/bar/baz']
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)
    strategy.arguments['slack_webhook_url'].each do |webhook_url|
      webhook = stub_request(:post, webhook_url.strip).with(
        body: {
          text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).to_return(status: 201)
      DeployService.new(strategy).start
      # notification not repeated
      DeployService.new(strategy).start
      expect(webhook).not_to have_been_made
    end
  end

  it 'fails to notifies one Slack prior to automatically merging release PR due invalid url string' do
    strategy.update!(arguments: strategy.arguments.merge(
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i,
      slack_webhook_url: ['invalidstring'],
      blocked_time_buckets: []
    ))
    allow_any_instance_of(Octokit::Client).to receive(:create_pull_request)
      .with('artsy/candela', 'release', 'staging', anything, anything)
      .and_raise(Octokit::UnprocessableEntity)
    allow_any_instance_of(Octokit::Client).to receive(:pull_requests)
      .with('artsy/candela', base: 'release', head: 'staging')
      .and_return([assigned_github_pull_request])
    expect_any_instance_of(Octokit::Client).not_to receive(:merge_pull_request)
    strategy.arguments['slack_webhook_url'].each do |webhook_url|
      webhook = stub_request(:post, webhook_url.strip).with(
        body: {
          text: 'The following changes will be released in about 1 hour: https://github.com/artsy/candela/pull/342'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      ).to_return(status: 201)
      DeployService.new(strategy).start
      # notification not repeated
      DeployService.new(strategy).start
      expect(webhook).not_to have_been_made
    end
  end

  it 'failed to release due blocked time' do
    strategy.update!(arguments: strategy.arguments.merge(
      blocked_time_buckets: ['* 1-23 * * *'],
      merge_after: 26.hours.to_i,
      merge_prior_warning: 75.minutes.to_i
    ))
    expect_any_instance_of(Octokit::Client).not_to receive(:create_pull_request)
    DeployService.new(strategy).start
  end
end
