class RejectedAtForHits < ActiveRecord::Migration
  def self.up
    add_column :hits, :rejected_at, :datetime
  end

  def self.down
    remove_column :hits, :rejected_at
  end
end
