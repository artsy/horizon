class AddErrorMessageToSnapshot < ActiveRecord::Migration[5.2]
  def change
    add_column :snapshots, :error_message, :string
  end
end
