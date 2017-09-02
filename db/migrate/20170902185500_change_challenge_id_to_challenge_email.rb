class ChangeChallengeIdToChallengeEmail < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :challenged_id
    add_column :games, :challenged_email, :string
  end
end
