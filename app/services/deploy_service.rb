class DeployService
  def self.start(deploy_strategy)
    case deploy_strategy.provider
    when 'github pull request' then create_github_pull_request(deploy_strategy)
    else raise NotImplementedError
    end
  end

  def self.create_github_pull_request(deploy_strategy)
    access_token = deploy_strategy.profile&.basic_password
    raise 'profile.basic_password is required for Github authentication' if access_token.blank?

    client = Octokit::Client.new(access_token: access_token)
    begin
      res = client.create_pull_request(
        deploy_strategy.github_repo,
        deploy_strategy.arguments['base'],
        deploy_strategy.arguments['head'],
        'Deploy',
        'This is an automatically generated release PR!'
      )
    rescue Octokit::UnprocessableEntity
      # PR already exists
    end    
  end
end

