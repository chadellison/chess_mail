class CreateMoveRanks < ActiveRecord::Migration[5.1]
  def change
    create_table :move_ranks do |t|
      t.string :position_signature
      t.integer :value
      t.timestamps
    end
  end
end
