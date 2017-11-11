class AddNotationToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :moves, :notation, :string
  end
end
