class CreateMHits < ActiveRecord::Migration
  def self.up
    create_table :m_hits do |t|      
      t.string :mturk_hit_id
      t.string :mturk_group_id
      t.integer :experimental_group, :limit => 1
      t.integer :experimental_country, :limit => 1
      t.text :wage_schedule
      t.string :current_mturk_worker_id
      t.integer :version_number
      t.timestamps
    end
    add_index :m_hits, :mturk_hit_id
  end

  def self.down
    drop_table :m_hits
  end
end
