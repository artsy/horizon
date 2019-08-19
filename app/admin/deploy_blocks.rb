ActiveAdmin.register DeployBlock do
  actions :all, except: [:destroy]

  permit_params :resolved_at, :description, :project_id

  form do |f|
    semantic_errors
    inputs do
      input :project
      input(
        :resolved_at,
        as: :date_time_picker,
        datepicker_options: { formatTime: 'g:ia' },
        label: "Resolved At (TZ: Eastern Time)"
      )
      input :description
    end
    actions
  end
end
