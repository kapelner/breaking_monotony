class CreateWorkerAdminComments < ActiveRecord::Migration
  def self.up
    create_table :worker_admin_comments do |t|
      t.integer :user_id
      t.integer :worker_id
      t.text :body
      t.datetime :created_at
    end
    add_index :worker_admin_comments, :worker_id
  end

  def self.down
    drop_table :worker_admin_comments
  end
end
