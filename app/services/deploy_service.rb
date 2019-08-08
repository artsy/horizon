class DeployService
  def self.start(deploy_strategy)
    if deploy_strategy.provider == 'github pull request'
      create_github_pr(deploy_strategy)
    end
    # raise NotImplementedError unless deploy_strategy.provider == 'github pull request'
  end

  def self.create_github_pr(deploy_strategy)
    access_token = deploy_strategy.profile&.basic_password
    raise 'profile.basic_password is required for Github authentication' if access_token.blank?
    client = Octokit::Client.new(:access_token => access_token)
    
    begin
      res = client.create_pull_request(
        deploy_strategy.github_repo,
        deploy_strategy.arguments["base"],
        deploy_strategy.arguments["head"],
        "Deploy",
        "This is an auto-generated release!"
      )
    rescue Octokit::UnprocessableEntity
      # PR already exists
    end    
  end
end

