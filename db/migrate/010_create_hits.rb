class CreateHits < ActiveRecord::Migration
  def self.up
    create_table :hits do |t|
      t.integer :qualified_worker_id
      t.integer :image_id, :null => false #needs an image
      t.float :wage, :null => false #needs a wage
      t.integer :experimental_group, :limit => 1, :null => false #needs a group
      t.integer :experimental_country, :limit => 1, :null => false #needs a country
      t.integer :set_number, :limit => 3, :null => false #needs a set number
      t.datetime :accepted_at
      t.text :points
      t.text :log
      t.float :accuracy
      t.string :mturk_hit_id
      t.string :mturk_group_id
      t.string :mturk_assignment_id
      t.datetime :submitted_at
      t.datetime :created_at
    end

    add_index :hits, :qualified_worker_id
    add_index :hits, :set_number
  end

  def self.down
    drop_table :hits
  end
end
