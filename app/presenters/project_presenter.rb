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

  def kubernetes?
    ordered_stages&.any? { |s| !s.hokusai&.empty? }
  end

  def block
    blocks = deploy_blocks.unresolved.to_a
    blocks.first
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
      comparedStages: compared_stages,
      gitRemote: git_remote,
      block: block,
      isFullyReleased: fully_released?,
      isKubernetes: kubernetes?,
      name: name.titleize,
      orderedStages: ordered_stages,
      severity: severity
    }
    attributes.merge(computed_attributes)
  end
end
