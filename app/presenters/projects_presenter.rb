class ProjectsPresenter
  GITHUB_REMOTE_EXPR = /https:\/\/github.com\/(?<org>[^\/]+)\/(?<project>[^\.]+).git/

  def initialize(params)
    @params = params
    @released_projects = released_projects()
    @unreleased_projects = unreleased_projects()
    @detailed_projects = detailed_projects()
  end

  def detailed_projects
    projects.sort_by { |p| [p.fully_released? ? 1 : 0, p.name] }
  end

  def unreleased_projects
    projects.reject(&:fully_released?).sort_by(&:severity).reverse
  end

  def released_projects
    projects.select(&:fully_released?).sort_by(&:name)
  end

  class ProjectWrapper
    attr_accessor :project
    delegate :name, :snapshot, :id, :description, :deploy_blocks, to: :project

    def initialize(project)
      @project = project
    end

    def ordered_stages
      @ordered_stages ||= project.stages.sort_by(&:position)
    end

    def fully_released?
      snapshot && severity == 0
    end

    def severity
      scores = compared_stages.to_a.map { |stage| stage[:score] }
      scores.compact.max || 0
    end

    def git_remote
      stage = ordered_stages&.detect{ |s| s.name == "master" }
      stage && stage.git_remote
    end

    def is_kubernetes?
      hokusai_stages = ordered_stages&.detect{ |s| s.hokusai }
      !hokusai_stages.nil?
    end

    def blocked?
      blocks = deploy_blocks.unresolved.to_a
      blocks.any?
    end

    # enumerates pairs of stages, the corresponding comparison object, and severity score
    def compared_stages
      @compared_stages ||= ordered_stages.each_cons(2).map do |ahead, behind|
        comparison = snapshot&.comparisons&.detect{ |c| c.behind_stage_id == behind.id && c.ahead_stage_id == ahead.id }
        {
          stages: [ahead, behind],
          snapshot: comparison,
          diff: diff_commits(comparison),
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
          firstName: line[:name].split(' ')[0],
          gravatar: gravatar_from_log_line(line),
          href: link_from_log_line(line),
          message: line
        }
      end
    end

    def link_from_log_line(line)
      github_match = ordered_stages.first&.git_remote&.match(GITHUB_REMOTE_EXPR)
      return if !github_match
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
        isBlocked: blocked?,
        isFullyReleased: fully_released?,
        isKubernetes: is_kubernetes?,
        name: name.titleize,
        orderedStages: ordered_stages,
        severity: severity,
      }
      attributes.merge(computed_attributes)
    end
  end

  private

  def projects
    @projects ||= begin
      query = Project.includes(:stages, snapshot: [:comparisons]).where(@params.permit(:organization_id))
      query = query.where('tags ?| array[:tags]', tags: @params[:tags]) if @params[:tags]&.any?
      query.map { |p| ProjectWrapper.new(p) }
    end
  end
end
