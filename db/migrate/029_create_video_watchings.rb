class CreateVideoWatchings < ActiveRecord::Migration
  def self.up
    create_table :video_watchings do |t|
      t.integer :worker_id
      t.datetime :created_at
    end
    add_index :video_watchings, :worker_id
  end

  def self.down
    drop_table :video_watchings
  end
end
