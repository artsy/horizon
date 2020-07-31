# frozen_string_literal: true

class DeployService
  attr_accessor :deploy_strategy

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

    # merge release PR if merge_after is specified by deploy_strategy
    if (merge_after = deploy_strategy.arguments['merge_after']) &&
       Time.now > (pull_request.created_at + merge_after.seconds)
      github_client.merge_pull_request(github_repo, pull_request.number)
      return
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

  def choose_assignee(pull_request)
    github_client
      .pull_request_commits(github_repo, pull_request.number)
      .flat_map { |c| [c.author, c.committer] }
      .reject { |c| c.type == 'Bot' || c.login == 'web-flow' || c.login[/\bbot\b/] }
      .group_by(&:login).map { |k, v| [v.size, k] }.sort.reverse.map(&:last)
      .detect { |l| github_client.check_assignee(github_repo, l) }
  end
end
