class ComparisonService
  attr_accessor :project

  KEEP_OLD_SNAPSHOTS = 5

  def initialize(project)
    @project = project
  end

  def self.refresh_all_comparisons
    Project.all.each do |project|
      new(project).refresh_comparisons
    end
  end

  def refresh_comparisons
    Dir.mktmpdir(['releasecop', project.name]) do |dir|
      checker = Releasecop::Checker.new(
        project.name,
        project.stages.order(position: :asc).map{|s| build_manifest_item(s) },
        dir
      )
      refreshed_at = Time.now
      result = checker.check # build comparisons
      if project.snapshot && equivalent_snapshots?(project.snapshot, result)
        project.snapshot.update!(refreshed_at: refreshed_at)
      else
        store_new_snapshot!(project, result, refreshed_at)
        clean_up_old_snapshots
      end
    end
  end

  private

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
    snapshot.comparisons.order(position: :asc).map(&:description) == result.comparisons.map(&:lines)
  end

  def store_new_snapshot!(project, result, refreshed_at)
    project.snapshots.create!(refreshed_at: refreshed_at).tap do |snapshot|
      result.comparisons.each do |c|
        snapshot.comparisons.create!(
          behind_stage: project.stages.detect { |s| s.name == c.behind.name },
          ahead_stage: project.stages.detect { |s| s.name == c.ahead.name },
          released: !c.unreleased?,
          description: c.lines
        )
      end
      project.update(snapshot: snapshot)
    end
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
