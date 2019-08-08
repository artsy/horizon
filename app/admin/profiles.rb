ActiveAdmin.register Profile do
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

  permit_params :name, :organization_id, :basic_username, :basic_password, :environment_input

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :organization
      f.input :basic_username
      f.input :basic_password
      f.input :environment_input, as: :text, label: 'Environment'
    end
    f.actions
  end
end
