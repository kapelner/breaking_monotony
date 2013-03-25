class CreateWorkerInformations < ActiveRecord::Migration
  def self.up
    create_table :worker_informations do |t|
      t.string :worker_id
      t.integer :number_in_box
      t.integer :male_female, :limit => 1
      t.boolean :trouble_red_green
      t.boolean :trouble_blue_yellow
      t.integer :age
      t.datetime :created_at
    end
    add_index :worker_informations, :worker_id, :unique => true
  end

  def self.down
    drop_table :worker_informations
  end
end
