class AddDescriptionToProject < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :description, :string
  end
end
