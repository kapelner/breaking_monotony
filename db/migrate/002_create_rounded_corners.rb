class CreateRoundedCorners < ActiveRecord::Migration
  def self.up
    create_table :rounded_corners do |t|      
      t.integer :radius
      t.string :border
      t.string :interior
      t.datetime :created_at
    end
    add_index :rounded_corners, :radius #we should index at least one to make the searching faster   
  end

  def self.down
    drop_table :rounded_corners
  end
end
