class AddComputedDataToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :ci_provider, :string
    add_column :projects, :renovate, :boolean
    add_column :projects, :orbs, :string, array: true, default: []
  end
end
