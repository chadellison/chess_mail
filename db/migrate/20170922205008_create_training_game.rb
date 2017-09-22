class CreateTrainingGame < ActiveRecord::Migration[5.1]
  def change
    create_table :training_games do |t|
      t.text :moves
      t.string :outcomve
    end
  end
end
