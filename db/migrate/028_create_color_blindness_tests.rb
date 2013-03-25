class CreateColorBlindnessTests < ActiveRecord::Migration
  def self.up
    create_table :color_blindness_tests do |t|
      t.integer :worker_id
      t.integer :number_in_box
      t.integer :male_female, :limit => 1
      t.boolean :trouble_red_green
      t.boolean :trouble_blue_yellow
      t.integer :age
      t.string :word
      t.datetime :created_at
    end
    add_index :color_blindness_tests, :worker_id, :unique => true
  end

  def self.down
    drop_table :color_blindness_tests
  end
end
