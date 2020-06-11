class ProjectsController < ApplicationController
  def index
    presenter = ProjectsPresenter.new(params)
    @props = {
      params: params,
      releasedProjects: presenter.released_projects,
      unreleasedProjects: presenter.unreleased_projects,
      projects: [presenter.detailed_projects]
    }
  end
end
