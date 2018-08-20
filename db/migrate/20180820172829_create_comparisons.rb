class CreateComparisons < ActiveRecord::Migration[5.2]
  def change
    create_table :comparisons do |t|
      t.references :snapshot, foreign_key: true
      t.references :ahead_stage, foreign_key: { to_table: :stages }
      t.references :behind_stage, foreign_key: { to_table: :stages }
      t.boolean :released
      t.text :description, array: true, default: []
      t.integer :position

      t.timestamps
    end
  end
end
