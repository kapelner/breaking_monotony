class IndexIpAddressOnViews < ActiveRecord::Migration
  def self.up
    add_index :hit_viewings, :ip_address
  end

  def self.down
    remove_index :hit_viewings, :ip_address
  end
end
