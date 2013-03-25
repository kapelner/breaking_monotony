class IndexBbPs < ActiveRecord::Migration
  def self.up
    add_index :big_brother_params, :big_brother_track_id
  end

  def self.down
    remove_index :big_brother_params, :big_brother_track_id
  end
end
