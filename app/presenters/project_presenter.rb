# frozen_string_literal: true

class ProjectPresenter
  attr_accessor :project

  delegate :name, :snapshot, :id, :description, :tags, :deploy_blocks, to: :project

  GITHUB_REMOTE_EXPR = %r{https://github.com/(?<org>[^/]+)/(?<project>[^.]+).git}.freeze

  def initialize(project)
    @project = project
  end

  def ordered_stages
    @ordered_stages ||= project.stages.sort_by(&:position)
  end

  def fully_released?
    snapshot && severity.zero?
  end

  def severity
    scores = compared_stages.to_a.map { |stage| stage[:score] }
    scores.compact.max || 0
  end

  def git_remote
    stage = ordered_stages&.detect { |s| s.name == 'master' }
    stage&.git_remote
  end

  def auto_deploys?
    @project.stages.any? { |s| s.deploy_strategies.any?(&:automatic?) }
  end

  def kubernetes?
    ordered_stages&.any? { |s| s.hokusai&.length&.positive? }
  end

  def dependencies_up_to_date?
    dependencies_with_unknown_status.empty? && dependencies_with_update_required.empty?
  end

  def dependencies_with_unknown_status
    @project.dependencies.select { |d| d.version.include?('unknown') }
  end

  def dependencies_with_update_required
    @project.dependencies.select(&:update_required)
  end

  def block
    blocks = deploy_blocks.unresolved.to_a
    blocks.first
  end

  def maintenance_messages
    messages = []
    dependencies_with_unknown_status&.any? do |d|
      messages.push "Dependency #{d.name} version unknown, add a version declaration file to the project."
    end
    dependencies_with_update_required&.any? do |d|
      expectation = Horizon.config.stringify_keys["minimum_version_#{d.name}"]
      messages.push(
        "Dependency #{d.name} uses an unsupported version.#{expectation && " Update to v#{expectation} or higher."}"
      )
    end
    if !auto_deploys? && kubernetes?
      messages.push(
        "Create deploy strategies with 'automated: true' to enable automated deploy PRs"
      )
    end
    if @project.orbs.any? && kubernetes?
      messages.push(
        'Enable Renovate to receive automatic PRs when orb versions change.'
      )
    end
    messages
  end

  # enumerates pairs of stages, the corresponding comparison object, and severity score
  def compared_stages
    @compared_stages ||= ordered_stages.each_cons(2).map do |ahead, behind|
      comparison = snapshot&.comparisons&.detect { |c| c.behind_stage_id == behind.id && c.ahead_stage_id == ahead.id }
      {
        stages: [ahead, behind],
        snapshot: comparison,
        diff: diff_commits(comparison),
        blame: diff_blame(comparison),
        score: (ComparisonService.comparison_score(comparison) if comparison)
      }
    end
  end

  def diff_commits(comparison)
    return if comparison.nil?

    comparison.description.map do |l|
      line = ReleasecopService.parsed_log_line(l)
      {
        sha: line[:sha],
        date: line[:date],
        firstName: first_name_from_log_line(line),
        gravatar: gravatar_from_log_line(line),
        href: link_from_log_line(line),
        message: line[:message]
      }
    end
  end

  def diff_blame(comparison)
    return if comparison.nil?

    names = comparison.description.map do |l|
      line = ReleasecopService.parsed_log_line(l)
      first_name_from_log_line(line)
    end
    names.uniq.to_sentence
  end

  def first_name_from_log_line(line)
    name = line[:name] && line[:name].split(' ')[0]
    name&.titleize
  end

  def link_from_log_line(line)
    github_match = ordered_stages.first&.git_remote&.match(GITHUB_REMOTE_EXPR)
    return unless github_match

    "https://github.com/#{github_match[:org]}/#{github_match[:project]}/commit/#{line[:sha]}"
  end

  def gravatar_from_log_line(line)
    return if line[:email].blank?

    hash = Digest::MD5.hexdigest(line[:email].downcase)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def as_json(_options = nil)
    attributes = @project.as_json
    computed_attributes = {
      block: block,
      comparedStages: compared_stages,
      dependencies: @project.dependencies,
      dependenciesUpToDate: dependencies_up_to_date?,
      gitRemote: git_remote,
      isAutoDeploy: auto_deploys?,
      isFullyReleased: fully_released?,
      isKubernetes: kubernetes?,
      maintenanceMessages: maintenance_messages,
      name: name.titleize,
      orderedStages: ordered_stages,
      severity: severity
    }
    attributes.merge(computed_attributes)
  end
end
