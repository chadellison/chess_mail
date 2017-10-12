class AddMoveSignatureToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :move_signature, :string
  end
end
