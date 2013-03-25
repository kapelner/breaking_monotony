class CreateWorkerComments < ActiveRecord::Migration
  def self.up
    create_table :worker_comments do |t|
      t.integer :hit_id
      t.text :comments
      t.timestamps
    end
  end

  def self.down
    drop_table :worker_comments
  end
end
