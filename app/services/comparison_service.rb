class ComparisonService
  attr_accessor :project

  KEEP_OLD_SNAPSHOTS = 5

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
    result = perform_comparison
    new_snapshot = nil
    if project.snapshot && equivalent_snapshots?(project.snapshot, result)
      project.snapshot.update!(refreshed_at: refreshed_at)
    else
      new_snapshot = store_new_snapshot!(project, result, refreshed_at)
      clean_up_old_snapshots
    end
    new_snapshot
  end

  private

  def perform_comparison
    Dir.mktmpdir(['releasecop', project.name]) do |dir|
      checker = Releasecop::Checker.new(
        project.name,
        project.stages.order(position: :asc).map{|s| build_manifest_item(s) },
        dir
      )
      ResultWrapper.new(checker) # build comparisons
    end
  end

  class ResultWrapper
    attr_accessor :result, :error

    def initialize(checker)
      begin
        @result = checker.check
      rescue => ex
        self.error = ex
      end
    end

    def comparisons
      @result&.comparisons || []
    end
  end

  def build_manifest_item(stage)
    {
      'name' => stage.name,
      'git' => construct_git(stage),
      'tag_pattern' => stage.tag_pattern.presence,
      'branch' => stage.branch.presence,
      'hokusai' => stage.hokusai.presence,
      'aws_access_key_id' => stage.profile&.environment&.fetch('AWS_ACCESS_KEY_ID'),
      'aws_secret_access_key' => stage.profile&.environment&.fetch('AWS_SECRET_ACCESS_KEY')
    }
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

  def construct_git(stage)
    if stage.profile&.basic_username || stage.profile&.basic_password
      uri = URI(stage.git_remote)
      uri.user = stage.profile&.basic_username
      uri.password = stage.profile&.basic_password
      uri.to_s
    else
      stage.git_remote
    end
  end
end
