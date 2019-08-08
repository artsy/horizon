ActiveAdmin.register DeployStrategy do
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
  belongs_to :stage

  permit_params :provider, :automatic, :profile_id, :arguments_input

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
        f.input :provider, as: :select, collection: DeployStrategy::PROVIDERS
        f.input :profile
        f.input :automatic
        f.input :arguments_input, label: 'Arguments (JSON)'
    end
    f.actions
  end

end
