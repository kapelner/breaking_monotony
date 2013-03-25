class CreateWantToLeaves < ActiveRecord::Migration
  def self.up
    create_table :want_to_leaves do |t|
      t.integer :worker_id
      t.datetime :created_at
    end
    add_index :want_to_leaves, :worker_id
  end

  def self.down
    drop_table :want_to_leaves
  end
end
