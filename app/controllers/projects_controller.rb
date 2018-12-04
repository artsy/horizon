# frozen_string_literal: true

class ProjectsController < ApplicationController
  def index
    @organization_id = projects_params[:organization_id]
    @projects = Project.where(projects_params).sort_by do |project|
      [project.fully_released? ? 1 : 0, project.name]
    end
  end

  def simple
    @organization_id = params[:organization_id]
    @projects = Project.where(projects_params).to_a
    @released = @projects.select(&:fully_released?).sort_by(&:name)
    @needs_work = @projects.reject(&:fully_released?).sort_by { |p| p.snapshots.length }
  end

  private

  def projects_params
    params.permit(:organization_id)
  end
end
