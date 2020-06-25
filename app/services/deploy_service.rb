# frozen_string_literal: true

class DeployService
  def self.start(deploy_strategy)
    case deploy_strategy.provider
    when 'github pull request' then create_github_pull_request(deploy_strategy)
    else raise NotImplementedError
    end
  end

  def self.create_github_pull_request(deploy_strategy) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    access_token = deploy_strategy.profile&.basic_password
    raise 'A profile and basic_password are required for Github authentication' if access_token.blank?

    repo = deploy_strategy.github_repo
    client = Octokit::Client.new(access_token: access_token)
    begin
      pr = client.create_pull_request(
        repo,
        deploy_strategy.arguments['base'],
        deploy_strategy.arguments['head'],
        'Deploy',
        'This is an automatically generated release PR!'
      )

      # assign appropriate github user
      sorted_logins = client.pull_request_commits(repo, pr.number)
                            .flat_map { |c| [c.author, c.committer] }
                            .reject { |c| c.type == 'Bot' || c.login == 'web-flow' || c.login[/\bbot\b/] }
                            .group_by(&:login).map { |k, v| [v.size, k] }.sort.reverse.map(&:last)
      assignee = sorted_logins.detect { |l| client.check_assignee(repo, l) }
      client.add_assignees(repo, pr.number, assignee) if assignee
    rescue Octokit::UnprocessableEntity
      # PR already exists
    end
  end
end
