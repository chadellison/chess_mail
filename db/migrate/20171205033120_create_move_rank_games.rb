class CreateMoveRankGames < ActiveRecord::Migration[5.1]
  def change
    create_table :move_rank_games do |t|
      t.integer :game_id
      t.integer :move_rank_id
      t.timestamps
    end
  end
end
