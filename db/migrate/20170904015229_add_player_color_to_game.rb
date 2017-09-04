class AddPlayerColorToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :player_color, :string
  end
end
