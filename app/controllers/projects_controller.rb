class ProjectsController < ApplicationController
  def index
    @projects = Project.where(projects_params).order('name ASC')
  end

  private

  def projects_params
    params.permit(:organization_id)
  end
end
