ActiveAdmin.register Project do
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
  sidebar 'Associated Data', only: %i[show edit] do
    ul do
      li link_to 'Stages', admin_project_stages_path(project)
    end
  end

  permit_params :organization_id, :name
end
