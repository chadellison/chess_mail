class AddIndexToSignature < ActiveRecord::Migration[5.1]
  def change
    add_index :games, :move_signature
  end
end
