class Add < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :playerColor
    add_column :games, :challengerColor, :string
  end
end
