class AddStartIndexToPiece < ActiveRecord::Migration[5.1]
  def change
    add_column :pieces, :startIndex, :integer
  end
end
