class AddNotationToPiece < ActiveRecord::Migration[5.1]
  def change
    add_column :pieces, :notation, :string
  end
end
