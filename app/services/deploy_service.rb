# frozen_string_literal: true

class DeployService
  include ActionView::Helpers::DateHelper

  attr_accessor :deploy_strategy

  MERGE_PRIOR_WARNING = 1.hour

  def initialize(deploy_strategy)
    self.deploy_strategy = deploy_strategy
  end

  def start
    case deploy_strategy.provider
    when 'github pull request' then create_github_pull_request
    else raise NotImplementedError
    end
  end

  private

  def create_github_pull_request
    pull_request = github_client.create_pull_request(
      github_repo,
      deploy_strategy.arguments['base'],
      deploy_strategy.arguments['head'],
      'Deploy',
      'This is an automatically generated release PR!'
    )

    assignee = choose_assignee(pull_request)
    github_client.add_assignees(github_repo, pull_request.number, assignee) if assignee
  rescue Octokit::UnprocessableEntity # release PR already exists
    pull_request = github_client.pull_requests(
      github_repo,
      base: deploy_strategy.arguments['base'],
      head: deploy_strategy.arguments['head']
    ).first || return

    if (merge_after = deploy_strategy.arguments['merge_after'])
      merge_at = pull_request.created_at + merge_after.seconds
      if Time.now > merge_at # merge release PR automatically
        # re-request individual PR so mergeable attribute is available
        pull_request = github_client.pull_request(github_repo, pull_request.number)
        if pull_request.mergeable?
          github_client.merge_pull_request(github_repo, pull_request.number)
          return
        end
      end

      warn_at = merge_at - deploy_strategy.arguments.fetch('merge_prior_warning', MERGE_PRIOR_WARNING)
      if Time.now > warn_at &&
         (webhook_url = deploy_strategy.arguments['slack_webhook_url']) &&
         deploy_strategy.arguments['warned_pull_request_url'] != pull_request.html_url
        deliver_slack_webhook(pull_request, webhook_url, merge_at)
        deploy_strategy.update!(
          arguments: deploy_strategy.arguments.merge(warned_pull_request_url: pull_request.html_url)
        )
      end
    end

    if pull_request.assignee.blank? # try to assign if unassigned
      assignee = choose_assignee(pull_request)
      github_client.add_assignees(github_repo, pull_request.number, assignee) if assignee
    end
  end

  def github_client
    @github_client ||= Octokit::Client.new(access_token: github_access_token)
  end

  def github_repo
    @github_repo ||= deploy_strategy.github_repo
  end

  def github_access_token
    @github_access_token ||=
      deploy_strategy.profile&.basic_password.presence ||
      (raise 'A profile and basic_password are required for Github authentication')
  end

  def deliver_slack_webhook(pull_request, webhook_urls, merge_at)
    webhook_urls.split(',').each { |webhook_url| send_slack_alert(pull_request, webhook_url.strip, merge_at) sleep 1 }
  end

  def send_slack_alert(pull_request, webhook_url, merge_at)
    uri = URI.parse webhook_url
    request = Net::HTTP::Post.new(uri.request_uri)
    request['Content-Type'] = 'application/json'
    request.body = {
      text: "The following changes will be released in #{distance_of_time_in_words_to_now(merge_at)}: " +
            pull_request.html_url
    }.to_json
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.request(request)
  rescue StandardError => e
    Rails.logger.warn "Failed to deliver webhook to #{webhook_url.inspect} (#{e.message})"
  end

  def choose_assignee(pull_request)
    github_client
      .pull_request_commits(github_repo, pull_request.number)
      .flat_map { |c| [c.author, c.committer] }
      .reject { |c| c.nil? || c.type == 'Bot' || c.login == 'web-flow' || c.login == 'artsyit' || c.login[/\bbot\b/] }
      .group_by(&:login).map { |k, v| [v.size, k] }.sort.reverse.map(&:last)
      .detect { |l| github_client.check_assignee(github_repo, l) }
  end
end
