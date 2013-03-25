class CheckedOverWorker < ActiveRecord::Migration
  def self.up
    add_column :workers, :manually_checked_over, :datetime
  end

  def self.down
    remove_column :workers, :manually_checked_over
  end
end
