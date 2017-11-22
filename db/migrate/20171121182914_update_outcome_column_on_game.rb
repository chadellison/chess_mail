class UpdateOutcomeColumnOnGame < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :outcome, :string
    add_column :games, :outcome, :integer
  end
end
