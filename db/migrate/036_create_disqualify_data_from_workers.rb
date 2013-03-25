class CreateDisqualifyDataFromWorkers < ActiveRecord::Migration
  def self.up
    create_table :disqualify_data_from_workers do |t|
      t.string :mturk_worker_id
      t.text :reason
      t.datetime :created_at
    end
    add_index :disqualify_data_from_workers, :mturk_worker_id, :unique => true
  end

  def self.down
    drop_table :disqualify_data_from_workers
  end
end
