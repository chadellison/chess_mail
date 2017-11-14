class CreatePositionAnalytics < ActiveRecord::Migration[5.1]
  def change
    create_table :position_analytics do |t|
      t.string :pieceType
      t.string :position
      t.string :outcome
      t.timestamps
    end
  end
end
