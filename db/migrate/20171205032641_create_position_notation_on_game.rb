class CreatePositionNotationOnGame < ActiveRecord::Migration[5.1]
  def change
    create_table :position_notation_on_games do |t|
      add_column :games, :position_signature, :string
    end
  end
end
