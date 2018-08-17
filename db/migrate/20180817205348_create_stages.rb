class CreateStages < ActiveRecord::Migration[5.2]
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :position
      t.references :project, foreign_key: true
      t.string :git_remote
      t.string :tag_pattern
      t.string :branch
      t.string :hokusai

      t.timestamps
    end
  end
end
