class AddStatusToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :pending, :boolean, default: true
  end
end
