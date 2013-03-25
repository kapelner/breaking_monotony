class CreateQualifiedWorkers < ActiveRecord::Migration
  def self.up
    create_table :qualified_workers do |t|
      t.string :worker_id
      t.string :ip_address
      t.integer :meaning_group, :limit => 1
      t.datetime :created_at
    end
    add_index :qualified_workers, :worker_id, :unique => true
  end

  def self.down
    drop_table :qualified_workers
  end
end
