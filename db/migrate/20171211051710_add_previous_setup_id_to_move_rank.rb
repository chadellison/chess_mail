class AddPreviousSetupIdToMoveRank < ActiveRecord::Migration[5.1]
  def change
    add_column :move_ranks, :next_position_id, :integer
  end
end
