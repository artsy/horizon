# frozen_string_literal: true

class ProjectPresenter
  attr_accessor :project

  delegate :name, :snapshot, :id, :description, :tags, :deploy_blocks, to: :project

  def initialize(project)
    @project = project
  end

  def fully_released?
    snapshot && severity.zero?
  end

  def severity
    scores = compared_stages.to_a.map { |stage| stage[:score] }
    scores.compact.max || 0
  end

  def maintenance_messages
    messages = []
    @project.dependencies_with_unknown_status&.any? do |d|
      messages.push "Dependency #{d.name} version unknown, add a version declaration file to the project."
    end
    @project.dependencies_with_update_required&.any? do |d|
      expectation = Horizon.config.stringify_keys["minimum_version_#{d.name}"]
      messages.push(
        "Dependency #{d.name} uses an unsupported version.#{expectation && " Update to v#{expectation} or higher."}"
      )
    end
    if !@project.auto_deploys? && @project.kubernetes?
      messages.push(
        "Create deploy strategies with 'automated: true' to enable automated deploy PRs"
      )
    end
    if @project.orbs.any? && @project.kubernetes? && !@project.renovate
      messages.push(
        "Enable Renovate to receive automatic PRs when orb versions change."
      )
    end
    messages
  end

  # enumerates pairs of stages, the corresponding comparison object, and severity score
  def compared_stages
    @compared_stages ||= project.stages.ordered.each_cons(2).map do |ahead, behind|
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
    name = line[:name] && line[:name].split[0]
    name&.titleize
  end

  def link_from_log_line(line)
    "#{project.github_repo_url}/commit/#{line[:sha]}"
  end

  def gravatar_from_log_line(line)
    return if line[:email].blank?

    hash = Digest::MD5.hexdigest(line[:email].downcase)
    "https://www.gravatar.com/avatar/#{hash}"
  end

  def as_json(_options = nil)
    attributes = @project.as_json
    computed_attributes = {
      comparedStages: compared_stages,
      isFullyReleased: fully_released?,
      maintenanceMessages: maintenance_messages,
      severity: severity,
      errorMessage: @project.snapshot&.error_message
    }
    attributes.merge(computed_attributes)
  end
end
