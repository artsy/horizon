# frozen_string_literal: true

module Api
  class DeployBlocksController < ApplicationController
    def index
      project = Project.find(params[:project_id])
      coerced_resolved_param =
        ActiveModel::Type::Boolean.new.cast(params[:resolved])

      scoped_deploy_blocks = filter_by_resolved(
        project.deploy_blocks,
        coerced_resolved_param
      )

      render json: scoped_deploy_blocks
    end

    private

    def filter_by_resolved(deploy_blocks, resolved_query_param)
      case resolved_query_param
      when true
        deploy_blocks.resolved
      when false
        deploy_blocks.unresolved
      else
        deploy_blocks
      end
    end
  end
end
