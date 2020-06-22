require 'base64'

class ProjectDataService

  def initialize(project, access_token)
    @project = project
    @access_token = access_token
    @client = Octokit::Client.new(access_token: access_token)
    @circle_config = circle_config
  end

  def self.refresh_data_for_org(org, access_token)
    org.projects.each do |project|
      new(project, access_token).update_computed_properties
    end
  end

  def update_computed_properties
    update_dependencies
    @project.update({
      ci_provider: ci_provider,
      renovate: has_renovate?,
      orbs: orbs
    })
  end

  def ci_provider
    'circleci' if @circle_config
  end

  def has_renovate?
    true if renovate_config
  end

  def orbs
    orbs = []
    @circle_config.include?('artsy/hokusai@') && orbs.push('hokusai')
    @circle_config.include?('artsy/yarn@') && orbs.push('yarn')
    orbs
  end

  def update_dependencies
    update_dependency('ruby', ruby_version)
    update_dependency('node', node_version)
  end

  def update_dependency(name, version)
    d = @project.dependencies.where(name: name) || Dependency.new
    d.update(name: name, version: version)
  end

  def ruby_version
    file = fetch_github_file('.ruby-version')
    return if !file
    decode_content(file) || 'unknown verion'
  end

  def node_version
    file = fetch_github_file('package.json')
    return if !file
    json = JSON.parse(decode_content(file))
    json['engines'] && json['engines']['node'] || 'unknown verion'
  end

  def circle_config
    file = fetch_github_file('.circleci/config.yml')
    return if !file
    decode_content(file)
  end

  def renovate_config
    file = fetch_github_file('renovate.json')
    return if !file
    decode_content(file)
  end

  def decode_content(file)
    Base64.decode64(file[:content]).gsub(/\n/, '')
  end

  def fetch_github_file(path)
    file = @client.contents("#{@project.github_repo}", :path => path)
    file && file.to_h
    rescue Octokit::NotFound
    # file not found - don't fail if ruby project doesn't have node etc
  end
end
