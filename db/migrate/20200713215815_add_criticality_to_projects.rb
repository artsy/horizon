class AddCriticalityToProjects < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :criticality, :integer, :default => 1
  end
end
