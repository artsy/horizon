ActiveAdmin.register Stage do
# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end
  belongs_to :project

  sidebar 'Associated Data', only: %i[show edit] do
    ul do
      li link_to 'Deploy Strategies', admin_stage_deploy_strategies_path(stage)
    end
  end

  permit_params :project_id, :profile_id, :name, :position, :git_remote, :tag_pattern, :branch, :hokusai
end
