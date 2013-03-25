class CreateQualifications < ActiveRecord::Migration
  def self.up
    create_table :qualifications do |t|
      t.integer :worker_id
      t.datetime :created_at
    end
    add_index :qualifications, :worker_id, :unique => true
  end

  def self.down
    drop_table :qualifications
  end
end
