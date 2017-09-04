class AddChallengedNameToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :challenged_name, :string
  end
end
