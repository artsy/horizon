class ProjectsController < ApplicationController
  def index
    @presenter = ProjectsPresenter.new(params)
  end
end
