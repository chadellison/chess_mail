class AddIndexToTrainingGameMoves < ActiveRecord::Migration[5.1]
  def change
    add_index :training_games, :moves
  end
end
