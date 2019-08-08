class CreateDeployBlocks < ActiveRecord::Migration[5.2]
  def change
    create_table :deploy_blocks do |t|
      t.references :project, foreign_key: true, index: true
      t.datetime :resolved_at
      t.text :description

      t.timestamps
    end
  end
end
