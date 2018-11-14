class CreateSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :snapshots do |t|
      t.references :project, foreign_key: true
      t.datetime :refreshed_at

      t.timestamps
    end
  end
end
