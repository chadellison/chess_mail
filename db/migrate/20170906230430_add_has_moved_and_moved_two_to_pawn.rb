class AddHasMovedAndMovedTwoToPawn < ActiveRecord::Migration[5.1]
  def change
    add_column :pieces, :hasMoved, :boolean, default: false
    add_column :pieces, :movedTwo, :boolean, default: false
  end
end
