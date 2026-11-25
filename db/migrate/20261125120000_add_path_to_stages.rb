class AddPathToStages < ActiveRecord::Migration[6.1]
  def change
    add_column :stages, :path, :string
  end
end
