class AddTrainingGameFile < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :training_game, :boolean
  end
end
