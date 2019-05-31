class AddTagsToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :tags, :jsonb
  end
end
