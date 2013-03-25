class CreateHitAcceptances < ActiveRecord::Migration
  def self.up
    create_table :hit_acceptances do |t|
      t.integer :hit_id
      t.string :ip_address
      t.string :worker_id
      t.integer :experimental_group, :limit => 1
      t.datetime :created_at
    end
    add_index :hit_acceptances, :hit_id
  end

  def self.down
    drop_table :hit_acceptances
  end
end
