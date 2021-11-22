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
    when 'github pull request' then create_or_update_github_pull_request
    else raise NotImplementedError
    end
  end

  private

  def create_or_update_github_pull_request
    pull_request = find_pull_request || create_pull_request
    assign_pull_request(pull_request) if pull_request.assignee.blank?
    return unless deploy_strategy.arguments['merge_after'] && deploy_strategy.can_release?

    merge_at = pull_request.created_at + deploy_strategy.arguments['merge_after'].seconds
    warn_at = merge_at - deploy_strategy.arguments.fetch('merge_prior_warning', MERGE_PRIOR_WARNING)

    if warn_at.past? &&
       (webhook_urls = deploy_strategy.arguments['slack_webhook_url']) &&
       deploy_strategy.arguments['warned_pull_request_url'] != pull_request.html_url &&
       (merge_at.past? || deploy_strategy.can_release?(merge_at))
      deliver_slack_webhooks(pull_request, webhook_urls, merge_at)
      deploy_strategy.update!(
        arguments: deploy_strategy.arguments.merge(warned_pull_request_url: pull_request.html_url)
      ) # keep track of deploys already warned about
      return
    end

    # must re-request pull request to get mergeable attribute
    if merge_at.past? && github_client.pull_request(github_repo, pull_request.number).mergeable?
      github_client.merge_pull_request(github_repo, pull_request.number)
    end
  rescue Octokit::UnprocessableEntity => e # release PR already exists
    Rails.logger.warn "Failed to create or update pull request: #{e.message}"
  end

  def find_pull_request
    github_client.pull_requests(
      github_repo,
      base: deploy_strategy.arguments['base'],
      head: deploy_strategy.arguments['head']
    ).first
  end

  def create_pull_request
    github_client.create_pull_request(
      github_repo,
      deploy_strategy.arguments['base'],
      deploy_strategy.arguments['head'],
      'Deploy',
      'This is an automatically generated release PR!'
    )
  end

  def assign_pull_request(pull_request)
    assignee = choose_assignee(pull_request)
    github_client.add_assignees(github_repo, pull_request.number, assignee) if assignee
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

  def validate_slack_webhook_url?(webhook_url)
    uri = URI.parse(webhook_url)
    uri.is_a?(URI::HTTPS) && !uri.host.nil?
  rescue URI::InvalidURIError
    Rails.logger.warn "Failed to deliver webhook to #{webhook_urls.inspect}, invalid url pattern"
    false
  end

  def deliver_slack_webhooks(pull_request, webhook_urls, merge_at)
    Array(webhook_urls).each do |webhook_url|
      send_slack_alert(pull_request, webhook_url.strip, merge_at)
    end
  rescue StandardError => e
    Rails.logger.warn "Failed to deliver webhook to #{webhook_urls.inspect} (#{e.message})"
  end

  def send_slack_alert(pull_request, webhook_url, merge_at)
    if validate_slack_webhook_url?(webhook_url)
      uri = URI.parse webhook_url
      request = Net::HTTP::Post.new(uri.request_uri)
      request['Content-Type'] = 'application/json'
      distance_of_time = merge_at.past? ? 'a few minutes' : distance_of_time_in_words_to_now(merge_at)
      request.body = {
        text: "The following changes will be released in #{distance_of_time}: #{pull_request.html_url}"
      }.to_json
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = (uri.scheme == 'https')
      http.request(request)
    end
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
