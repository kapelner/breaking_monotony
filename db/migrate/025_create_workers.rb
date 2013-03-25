class CreateWorkers < ActiveRecord::Migration
  def self.up
    create_table :workers do |t|
      t.integer :m_hit_id
      t.string :mturk_worker_id
      t.string :mturk_assignment_id
      t.integer :experimental_group, :limit => 1 #need to keep this, because bit flips
      t.string :ip_address
      t.datetime :finished_at
      t.datetime :created_at
    end
    add_index :workers, :m_hit_id
    add_index :workers, :mturk_worker_id
  end

  def self.down
    drop_table :workers
  end
end
