class AddGameOutcomeField < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :outcome, :string
  end
end
