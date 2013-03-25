class PaidAtForHiTs < ActiveRecord::Migration
  def self.up
    add_column :hits, :paid_at, :datetime
  end

  def self.down
    remove_column :hits, :paid_at
  end
end
