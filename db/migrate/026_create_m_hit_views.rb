class CreateMHitViews < ActiveRecord::Migration
  def self.up
    create_table :m_hit_views do |t|
      t.integer :m_hit_id
      t.string :ip_address
      t.datetime :created_at
    end
    add_index :m_hit_views, :m_hit_id
    add_index :m_hit_views, :ip_address
  end

  def self.down
    drop_table :m_hit_views
  end
end
