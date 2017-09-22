class AddMoveCountToTrainingGame < ActiveRecord::Migration[5.1]
  def change
    add_column :training_games, :move_count, :integer
  end
end
