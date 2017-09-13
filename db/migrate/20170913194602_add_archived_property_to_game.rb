class AddArchivedPropertyToGame < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :archived, :boolean, default: false
  end
end
