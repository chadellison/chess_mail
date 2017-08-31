class AddCamelCaseToPieceType < ActiveRecord::Migration[5.1]
  def change
    remove_column :pieces, :piece_type, :string
    add_column :pieces, :pieceType, :string
  end
end
