class ProjectsController < ApplicationController
  def index
    @organization_id = projects_params[:organization_id]
    @projects = Project.where(projects_params).sort_by do |project|
      [project.fully_released? ? 1 : 0, project.name]
    end
  end

  private

  def projects_params
    params.permit(:organization_id)
  end
end
