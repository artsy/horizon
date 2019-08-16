ActiveAdmin.register DeployBlock do
  belongs_to :project
  permit_params :description, :resolved_at
end
