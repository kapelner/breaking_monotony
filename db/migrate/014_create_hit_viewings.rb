class CreateHitViewings < ActiveRecord::Migration
  def self.up
    create_table :hit_viewings do |t|
      t.integer :hit_id
      t.string :ip_address
      t.datetime :created_at
    end
    add_index :hit_viewings, :hit_id

    add_column :worker_informations, :ip_address, :string
  end

  def self.down
    drop_table :hit_viewings
    remove_column :worker_informations, :ip_address
  end
end
