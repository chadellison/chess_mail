class ChangeUserToSnakeCase < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :firstName
    remove_column :users, :lastName
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
  end
end
