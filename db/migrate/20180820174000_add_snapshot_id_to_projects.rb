class AddSnapshotIdToProjects < ActiveRecord::Migration[5.2]
  def change
    add_reference :projects, :snapshot, foreign_key: true
  end
end
