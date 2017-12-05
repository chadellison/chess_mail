class AddDefaultValueToMoveRank < ActiveRecord::Migration[5.1]
  def change
    remove_column :move_ranks, :value
    add_column :move_ranks, :value, :integer, default: 0
  end
end
