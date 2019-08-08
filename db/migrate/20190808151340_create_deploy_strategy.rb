class CreateDeployStrategy < ActiveRecord::Migration[5.2]
  def change
    create_table :deploy_strategies do |t|
      t.string :provider
      t.jsonb :arguments
      t.references :stage, foreign_key: true
      t.references :profile, foreign_key: true
      t.boolean :automatic

      t.timestamps
    end
  end
end
