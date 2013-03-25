class AlterVideoWatchings < ActiveRecord::Migration
  def self.up
    add_column :video_watchings, :elapsed, :float
    add_column :video_watchings, :event_type, :string
  end

  def self.down
    remove_column :video_watchings, :elapsed
    remove_column :video_watchings, :event_type
  end
end
