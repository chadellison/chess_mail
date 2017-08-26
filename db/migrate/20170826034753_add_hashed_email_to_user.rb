class AddHashedEmailToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :hashed_email, :string
  end
end
