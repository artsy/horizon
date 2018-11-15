class CreateProfiles < ActiveRecord::Migration[5.2]
  def change
    create_table :profiles do |t|
      t.string :name
      t.references :organization, foreign_key: true
      t.string :basic_username
      t.string :basic_password
      t.jsonb :environment
      t.timestamps
    end

    add_reference :stages, :profile, foreign_key: true
  end
end
