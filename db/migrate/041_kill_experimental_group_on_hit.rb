class KillExperimentalGroupOnHit < ActiveRecord::Migration
  def self.up
    remove_column :m_hits, :experimental_group
  end

  def self.down
    add_column :m_hits, :experimental_group, :limit => 1
  end
end
