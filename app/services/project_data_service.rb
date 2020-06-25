# frozen_string_literal: true

require 'base64'

class ProjectDataService
  def initialize(project, access_token)
    @project = project
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
    @project.update(
      {
        ci_provider: ci_provider,
        renovate: renovate?,
        orbs: orbs
      }
    )
  end

  def ci_provider
    if @circle_config
      'circleci'
    elsif travis?
      'travis'
    end
  end

  def renovate?
    true if renovate_config
  end

  def orbs
    orbs = []
    @circle_config.include?('artsy/hokusai@') && orbs.push('hokusai')
    @circle_config.include?('artsy/yarn@') && orbs.push('yarn')
    orbs
  end

  def update_dependencies
    ruby_version && update_dependency('ruby', ruby_version)
    node_version && update_dependency('node', node_version)
  end

  def update_dependency(name, version)
    d = @project.dependencies.where(name: name)
    if d.empty?
      @project.dependencies << Dependency.create(name: name, version: version)
    else
      d.update(name: name, version: version)
    end
  end

  def ruby_version
    version_file = fetch_github_file('.ruby-version')
    gem_file = fetch_github_file('Gemfile') unless version_file
    return if !version_file && !gem_file

    decode_content(version_file) || 'unknown version'
  end

  def node_version
    package_file = fetch_github_file('package.json')
    return unless package_file

    json = JSON.parse(decode_content(package_file))
    engine = json['engines'] && json['engines']['node']
    nvmrc = fetch_github_file('.nvmrc') unless engine
    return decode_content(nvmrc) if nvmrc

    engine || 'unknown version'
  end

  def circle_config
    file = fetch_github_file('.circleci/config.yml')
    return unless file

    decode_content(file)
  end

  def travis?
    file = fetch_github_file('.travis.yml')
    true if file
  end

  def renovate_config
    file = fetch_github_file('renovate.json')
    return unless file

    decode_content(file)
  end

  def decode_content(file)
    Base64.decode64(file[:content]).gsub(/\n/, '') if file && file[:content]
  end

  def fetch_github_file(path)
    file = @client.contents(@project.github_repo.to_s, path: path)
    file&.to_h
  rescue Octokit::NotFound
    # file not found - don't fail if ruby project doesn't have node etc
  end
end
