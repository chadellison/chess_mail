class UpdateGameColumnsToCamelCase < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :challenged_email
    remove_column :games, :challenged_name
    remove_column :games, :player_color
    add_column :games, :challengedName, :string
    add_column :games, :challengedEmail, :string
    add_column :games, :playerColor, :string
    add_column :games, :human, :boolean, default: true
  end
end
