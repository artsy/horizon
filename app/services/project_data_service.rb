# frozen_string_literal: true

require 'base64'

class ProjectDataService
  def initialize(project)
    @project = project
    access_token = @project.organization.profiles.first.basic_password
    @client = Octokit::Client.new(access_token: access_token)
    @circle_config = circle_config
  end

  def self.refresh_data_for_org(org)
    org.projects.each do |project|
      new(project).update_computed_properties
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
    update_dependency('ruby', ruby_version) if ruby_version
    update_dependency('node', node_version) if node_version
  end

  def update_dependency(name, version)
    update_required = dependency_update_required(name, version)
    @project.dependencies.find_or_initialize_by(name: name)
            .update!(version: version, update_required: update_required)
  end

  def dependency_update_required(name, version)
    expectation = Horizon.config.stringify_keys["expected_version_#{name}"].split('.')
    return unless expectation && version

    current = version.delete('^0-9.').split('.')
    return if current.empty?

    major_needs_update = current[0] < expectation[0]
    minor_needs_update = expectation[1] && current[1] && current[1] < expectation[1]
    major_needs_update || minor_needs_update
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
    !!fetch_github_file('.travis.yml')
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
