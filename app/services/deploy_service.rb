class DeployService
  def self.start(deploy_strategy)
    case deploy_strategy.provider
    when 'github pull request'
      pr_info = create_github_pull_request(deploy_strategy)
      post_slack_notification(deploy_strategy, pr_info) if pr_info
    else raise NotImplementedError
    end
  end

  def self.create_github_pull_request(deploy_strategy)
    access_token = deploy_strategy.profile&.basic_password
    raise 'A profile and basic_password are required for Github authentication' if access_token.blank?

    repo = deploy_strategy.github_repo
    client = Octokit::Client.new(access_token: access_token)
    pr_info = nil
    begin
      pr = client.create_pull_request(
        repo,
        deploy_strategy.arguments['base'],
        deploy_strategy.arguments['head'],
        'Deploy',
        'This is an automatically generated release PR!'
      )

      # assign appropriate github user
      sorted_logins = client.pull_request_commits(repo, pr.number).
        flat_map{|c| [c.author, c.committer] }.
        reject{|c| c.type == 'Bot' || c.login == 'web-flow' || c.login[/\bbot\b/] }.
        group_by(&:login).map{|k,v| [v.size, k] }.sort.reverse.map(&:last)
      assignee = sorted_logins.detect { |l| client.check_assignee(repo, l) }
      client.add_assignees(repo, pr.number, assignee) if assignee
      pr_info = { html_url: pr.html_url, repo: repo }
    rescue Octokit::UnprocessableEntity
      # PR already exists
    end    
    pr_info
  end

  def self.post_slack_notification(deploy_strategy, pr_info)
    slack_channel = deploy_strategy.arguments['slack_channel']
    return unless slack_channel
    slack_token = deploy_strategy.profile&.environment&.fetch('SLACK_API_TOKEN')
    return unless slack_token
    slack = Slack::Web::Client.new(token: slack_token)
    slack.chat_postMessage(channel: slack_channel, message: "<#{pr_info.html_url}|Deploy PR> ready for #{pr_info.repo}", as_user: true)
  rescue StandardError
    # ok if we don't notify slack
  end
end

