# frozen_string_literal: true

class ProjectsPresenter
  def initialize(params)
    @params = params
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
      query.entries.map { |p| ProjectPresenter.new(p) }
    end
  end
end
