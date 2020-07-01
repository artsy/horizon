class AddUpdateRequiredToDependencies < ActiveRecord::Migration[6.0]
  def change
    add_column :dependencies, :update_required, :boolean
  end
end
