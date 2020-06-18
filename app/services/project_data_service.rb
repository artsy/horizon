require "base64"

class ProjectDataService

  def initialize(project, access_token)
    @project = project
    @access_token = access_token
    @client = Octokit::Client.new(access_token: access_token)
    @circle_config = circle_config
  end

  def github_org
    Organization.find(@project.organization_id).name
  end

  def project_name
    url = git_remote.split("/").last
    url.gsub(".git", "")
  end

  def git_remote
    stage = @project.stages&.detect{ |s| s.name == "master" }
    stage && stage.git_remote
  end

  def computed_properties
    {
      base_libraries: {
        ruby: ruby_version,
        node: node_version
      },
      ci_provider: ci_provider,
      renovate: has_renovate?,
      orbs: orbs
    }
  end

  def ci_provider
    @circle_config && "circleci"
  end

  def has_renovate?
    renovate_config && true
  end

  def orbs
    orbs = []
    @circle_config.include?("artsy/hokusai@") && orbs.push("hokusai")
    @circle_config.include?("artsy/yarn@") && orbs.push("yarn")
    orbs
  end

  def ruby_version
    file = fetch_github_file('.ruby-version')
    return if !file
    decode_content(file) || "unknown verion"
  end

  def node_version
    file = fetch_github_file('package.json')
    return if !file
    json = JSON.parse(decode_content(file))
    json["engines"]["node"] || "unknown verion"
  end

  def circle_config
    file = fetch_github_file('.circleci/config.yml')
    return if !file
    json = decode_content(file)
    json
  end

  def renovate_config
    file = fetch_github_file('renovate.json')
    return if !file
    json = decode_content(file)
    json
  end

  def decode_content(file)
    Base64.decode64(file[:content]).gsub(/\n/, '')
  end

  def fetch_github_file(path)
    file = @client.contents("#{github_org}/#{project_name}", :path => path)
    file && file.to_h
    rescue Octokit::NotFound
    # file not found - don't fail if ruby project doesn't have node etc
  end
end
