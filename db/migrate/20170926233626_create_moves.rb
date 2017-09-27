class CreateMoves < ActiveRecord::Migration[5.1]
  def change
    create_table :moves do |t|
      t.string :currentPosition
      t.string :color
      t.string :pieceType
      t.boolean :hasMoved, default: false
      t.boolean :movedTwo, default: false
      t.integer :startIndex
      t.integer :game_id
      t.timestamps
    end
  end
end
