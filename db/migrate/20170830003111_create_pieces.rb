class CreatePieces < ActiveRecord::Migration[5.1]
  def change
    create_table :pieces do |t|
      t.string :piece_type
      t.string :currentPosition
      t.string :color
      t.timestamps
    end
  end
end
