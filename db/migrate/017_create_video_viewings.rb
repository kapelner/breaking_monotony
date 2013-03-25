class CreateVideoViewings < ActiveRecord::Migration
  def self.up
    create_table :video_viewings do |t|
      t.integer :hit_id
      t.integer :experimental_group, :limit => 1
      t.string :ip_address
      t.string :worker_id      
      t.datetime :created_at
    end
    add_index :video_viewings, :hit_id
  end

  def self.down
    drop_table :video_viewings
  end
end
