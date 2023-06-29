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
    @circle_config.include?('artsy/auto@') && orbs.push('auto')
    @circle_config.include?('artsy/hokusai@') && orbs.push('hokusai')
    @circle_config.include?('artsy/release@') && orbs.push('release')
    @circle_config.include?('artsy/remote-docker@') && orbs.push('remote-docker')
    @circle_config.include?('artsy/yarn@') && orbs.push('yarn')
    orbs
  end

  def update_dependencies
    update_dependency('ruby', ruby_version) if ruby_version
    update_dependency('node', node_version) if node_version
  end

  def update_dependency(name, version)
    dependency = @project.dependencies.find_or_initialize_by(name: name)
    dependency.update(version: version)

    report_runtime_version_status(dependency)

    dependency
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

  def report_runtime_version_status(dependency)
    tags = [
      "runtime:#{dependency.name}",
      "project:#{@project.name}",
      "criticality:#{@project.criticality}",
      "tags:#{@project.tags&.none? ? 'none' : @project.tags.join(':')}"
    ]

    Horizon.dogstatsd.gauge(
      'runtime.version_status', # Metric name
      dependency.update_required? ? -1 : 1, # The value associated with the metric. -1 = out of date, 1 = up to date
      tags: tags
    )

    Horizon.dogstatsd.gauge(
      'runtime.version', # Metric name
      dependency.version,
      tags: tags
    )
  end
end
