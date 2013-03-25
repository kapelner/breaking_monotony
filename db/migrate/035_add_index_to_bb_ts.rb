class AddIndexToBbTs < ActiveRecord::Migration
  def self.up
    add_index :big_brother_tracks, :ip
  end

  def self.down
    remove_index :big_brother_tracks, :ip
  end
end
