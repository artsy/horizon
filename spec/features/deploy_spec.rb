require 'rails_helper'

RSpec.feature "Deploys", type: :feature do
  let(:org) { Organization.create!(name: 'artsy') }
  let(:project) { org.projects.create!(name: 'candela') }
  let(:stages) { (1..2).map {|i| project.stages.create!(name: "stage #{i}", git_remote: 'https://github.com/artsy/candela.git') } }
  let(:profile) { org.profiles.create!(basic_password: "foo") }
  let(:strategy) do
    stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: { base: 'release', head: 'staging' },
      profile: profile
    )
  end

  it "raises error unless profile.basic_password is present" do
    invalid_strategy = stages.last.deploy_strategies.create!(
      provider: 'github pull request',
      automatic: true,
      arguments: { base: 'release', head: 'staging' }
    )
    expect {
      DeployService.start(invalid_strategy)
    }.to raise_error('A profile and basic_password are required for Github authentication')
  end

  it "Sends an Octokit request to create pull request when initializing a client" do
    expect_any_instance_of(Octokit::Client).to receive(:create_pull_request)
    DeployService.start(strategy)
  end
end

