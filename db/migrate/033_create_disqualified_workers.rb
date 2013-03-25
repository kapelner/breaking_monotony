class CreateDisqualifiedWorkers < ActiveRecord::Migration
  def self.up
    create_table :disqualified_workers do |t|
      t.string :mturk_worker_id
      t.datetime :created_at
    end
    add_index :disqualified_workers, :mturk_worker_id, :unique => true
  end

  def self.down
    drop_table :disqualified_workers
  end
end
