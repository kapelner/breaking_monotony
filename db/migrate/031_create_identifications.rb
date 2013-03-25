class CreateIdentifications < ActiveRecord::Migration
  def self.up
    create_table :identifications do |t|
      t.integer :worker_id
      t.integer :image_id
      t.float :wage
      t.integer :set_number, :limit => 3
      t.text :points
      t.text :log
      t.float :precision
      t.float :recall
      t.datetime :started_at
      t.datetime :submitted_at
      t.datetime :created_at
    end
    add_index :identifications, :worker_id
  end

  def self.down
    drop_table :identifications
  end
end
