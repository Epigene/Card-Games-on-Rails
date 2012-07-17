class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :size
      t.integer :winner_id
      t.integer :position

      t.timestamps
    end
  end
end
