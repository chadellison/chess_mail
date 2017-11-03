class AddRobotBooleanField < ActiveRecord::Migration[5.1]
  def change
    add_column :games, :robot, :boolean
  end
end
