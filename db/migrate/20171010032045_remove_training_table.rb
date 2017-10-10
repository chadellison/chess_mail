class RemoveTrainingTable < ActiveRecord::Migration[5.1]
  def change
    drop_table :training_games
  end
end
