class ExpiredAtForMHits < ActiveRecord::Migration
  def self.up
    add_column :m_hits, :expire_at, :datetime
  end

  def self.down
    remove_column :m_hits, :expire_at
  end
end
