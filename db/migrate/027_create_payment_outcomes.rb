class CreatePaymentOutcomes < ActiveRecord::Migration
  def self.up
    create_table :payment_outcomes do |t|
      t.integer :worker_id
      t.boolean :rejected, :null => false, :default => false
      t.boolean :accepted, :null => false, :default => true
      t.boolean :never_submitted_therefore_never_paid, :null => false, :default => false
      t.float :total_payout, :null => false, :default => 0
      t.datetime :created_at
    end
    add_index :payment_outcomes, :worker_id, :unique => true
  end

  def self.down
    drop_table :payment_outcomes
  end
end
