class AddWarningPageBitToWorker < ActiveRecord::Migration
  def self.up
    add_column :workers, :warning_page_seen, :boolean, :default => false, :null => false
  end

  def self.down
    remove_column :workers, :warning_page_seen
  end
end
