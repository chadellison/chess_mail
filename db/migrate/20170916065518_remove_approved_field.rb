class RemoveApprovedField < ActiveRecord::Migration[5.1]
  def change
    remove_column :games, :archived, :string
  end
end
