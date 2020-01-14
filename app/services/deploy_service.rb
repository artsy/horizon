class DeployService
  def self.start(deploy_strategy, slack_token = nil)
    Slack.configure do |config|
      config.token = slack_token if slack_token
    end
    case deploy_strategy.provider
    when 'github pull request'
      create_github_pull_request(deploy_strategy)
      post_slack_notification if slack_token
    else raise NotImplementedError
    end
  end

  def self.create_github_pull_request(deploy_strategy)
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
      sorted_logins = client.pull_request_commits(repo, pr.number).
        flat_map{|c| [c.author, c.committer] }.
        reject{|c| c.type == 'Bot' || c.login == 'web-flow' || c.login[/\bbot\b/] }.
        group_by(&:login).map{|k,v| [v.size, k] }.sort.reverse.map(&:last)
      assignee = sorted_logins.detect { |l| client.check_assignee(repo, l) }
      client.add_assignees(repo, pr.number, assignee) if assignee
    rescue Octokit::UnprocessableEntity
      # PR already exists
    end    
  end

  def self.post_slack_notification()
    slack = Slack::Web::Client.new
    slack.chat_postMessage(channel: '#dev', message: "<#{pr.html_url}|Deploy PR> ready for #{repo}", as_user: true)
  rescue StandardError
    # ok if we don't notify slack
  end
end

