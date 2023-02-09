# frozen_string_literal: true

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
    f.semantic_errors(*f.object.errors.attribute_names)
    f.inputs do
      f.input :provider, as: :select, collection: DeployStrategy::PROVIDERS
      f.input :profile
      f.input :automatic
      f.input :arguments_input,
              label: 'Arguments (JSON)',
              hint: 'Supported properties: base (branch), head (branch), repo (e.g., org/project), merge_after (sec.),
              merge_prior_warning (sec., default 3600), slack_webhook_url, warned_pull_request_url,
              blocked_time_buckets'
    end
    f.actions
  end
end
