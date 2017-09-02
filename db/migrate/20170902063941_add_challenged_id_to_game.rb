class AddChallengedIdToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :challenged_id, :integer
  end
end
