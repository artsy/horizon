# frozen_string_literal: true

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
      li link_to 'Deploy Blocks', admin_deploy_blocks_path(q: { project_id_eq: project.id })
    end
  end

  permit_params :organization_id, :name, :description, :tags_input

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :organization
      f.input :name
      f.input :description
      f.input :tags_input, label: 'Tags (JSON array)'
    end
    f.actions
  end
end
