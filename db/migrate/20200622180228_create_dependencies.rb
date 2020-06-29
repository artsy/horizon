class CreateDependencies < ActiveRecord::Migration[6.0]
  def change
    create_table :dependencies do |t|
      t.references :project, foreign_key: true, index: true
      t.string :name
      t.string :version
    end
  end
end
