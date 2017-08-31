class AddCamelCaseBackToUser < ActiveRecord::Migration[5.1]
  def change
    remove_column :users, :first_name, :string
    remove_column :users, :last_name, :string
    add_column :users, :firstName, :string
    add_column :users, :lastName, :string
  end
end
