class ResolveTypo < ActiveRecord::Migration[5.1]
  def change
    remove_column :training_games, :outcomve
    add_column :training_games, :outcome, :string
  end
end
