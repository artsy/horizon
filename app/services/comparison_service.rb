class ComparisonService
  attr_accessor :project

  KEEP_OLD_SNAPSHOTS = 5
  DEPLOY_AT_SEVERITY = 10

  def initialize(project)
    @project = project
  end

  def self.refresh_all_comparisons
    new_snapshots = []
    Organization.all.map do |org|
      new_snapshots += refresh_comparisons_for_organization(org)
    end
    ActionCable.server.broadcast(ProjectChannel.channel_name, newSnapshots: true) if new_snapshots.any?
    new_snapshots
  end

  def self.comparison_score(comparison)
    severity_score(parsed_commits(comparison))
  end

  def self.parsed_commits(comparison)
    comparison.description.map { |l| ReleasecopService.parsed_log_line(l) }
  end

  # Calculates a score of how badly a deploy is needed based on commits, contributors, and age.
  def self.severity_score(commits)
    contributors = commits.map { |c| c[:email] }.uniq
    now = Time.now
    oldest_commit_at = commits.map { |c| c[:date] }.min&.to_time
    age = (now - (oldest_commit_at || now))/1.day
    commits.size + contributors.size**2 + age**2
  end

  def self.refresh_comparisons_for_organization(org)
    new_snapshots = []
    org.projects.each do |project|
      new_snapshots << new(project).refresh_comparisons
    end
    new_snapshots.compact!
    ActionCable.server.broadcast(ProjectChannel.channel_name(org.id), newSnapshots: true) if new_snapshots.any?
    new_snapshots
  end

  def refresh_comparisons
    refreshed_at = Time.now
    result = ReleasecopService.new(project).perform_comparison
    new_snapshot = nil
    if project.snapshot && equivalent_snapshots?(project.snapshot, result)
      project.snapshot.update!(refreshed_at: refreshed_at)
    else
      new_snapshot = store_new_snapshot!(project, result, refreshed_at)
      clean_up_old_snapshots
    end
    unless project.deploy_blocks.unresolved.any?
      project.stages.select { |s| warrants_deploy?(s) }.each do |stage|
        stage.deploy_strategies.each do |strategy|
          DeployService.start(strategy) if strategy.automatic?
        end
      end
    end
    new_snapshot
  end

  private

  def warrants_deploy?(stage)
    comparison = stage.project.snapshot.comparisons.detect do |c|
      c.behind_stage == stage
    end
    return false unless comparison

    self.class.comparison_score(comparison) > DEPLOY_AT_SEVERITY
  end

  def equivalent_snapshots?(snapshot, result)
    snapshot.comparisons.order(position: :asc).map(&:description) == result.comparisons.map(&:lines) &&
    snapshot.error_message == result.error&.message
  end

  def store_new_snapshot!(project, result, refreshed_at)
    snapshot = project.snapshots.create!(refreshed_at: refreshed_at, error_message: result.error&.message)
    result.comparisons.each do |c|
      snapshot.comparisons.create!(
        behind_stage: project.stages.detect { |s| s.name == c.behind.name },
        ahead_stage: project.stages.detect { |s| s.name == c.ahead.name },
        released: !c.unreleased?,
        description: c.lines
      )
    end
    project.update(snapshot: snapshot)
    snapshot
  end

  def clean_up_old_snapshots
    ids = project.snapshots.pluck(:id).sort
    return unless ids.size > KEEP_OLD_SNAPSHOTS
    project.snapshots.where('id < ?', ids[-KEEP_OLD_SNAPSHOTS]).destroy_all
  end
end
