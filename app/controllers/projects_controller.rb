class ProjectsController < ApplicationController
  def index
    presenter = ProjectsPresenter.new(params)
    @props = {
      params: params,
      releasedProjects: presenter.released_projects,
      unreleasedProjects: presenter.unreleased_projects,
      projects: presenter.detailed_projects,
      tags: tags
    }
  end

  def show
    project = Project.find(params[:id])
    @props = {
      project: ProjectPresenter.new(project),
      tags: tags
    }
  end

  private

  def tags
    Project.all.pluck(:tags).flatten.compact.uniq.sort
  end
end
