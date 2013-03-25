class AddHitAndExpGroupToWiAndQWs < ActiveRecord::Migration
  def self.up
    add_column :worker_informations, :hit_id, :integer
    add_column :worker_informations, :experimental_group, :integer, :limit => 1
    add_column :qualified_workers, :hit_id, :integer
    add_column :qualified_workers, :experimental_group, :integer, :limit => 1
  end

  def self.down
    remove_column :worker_informations, :hit_id
    remove_column :worker_informations, :experimental_group
    remove_column :qualified_workers, :hit_id
    remove_column :qualified_workers, :experimental_group
  end
end
