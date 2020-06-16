class ProjectsPresenter
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

  private

  def projects
    @projects ||= begin
      query = Project.includes(:stages, snapshot: [:comparisons]).where(@params.permit(:organization_id))
      query = query.where('tags ?| array[:tags]', tags: @params[:tags]) if @params[:tags]&.any?
      query.map { |p| ProjectPresenter.new(p) }
    end
  end
end

