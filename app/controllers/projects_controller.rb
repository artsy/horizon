class ProjectsController < ApplicationController
  def index
    @presenter = ProjectsPresenter.new(params)
    @props = {
      tags: tags
    }
  end

  private

  def tags
    Project.all.pluck(:tags).flatten.compact.uniq.sort
  end
end
