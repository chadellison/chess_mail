class AddIndexToPositionSignature < ActiveRecord::Migration[5.1]
  def change
    add_index :move_ranks, :position_signature
  end
end
