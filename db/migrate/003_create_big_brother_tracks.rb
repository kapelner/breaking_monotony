class CreateBigBrotherTracks < ActiveRecord::Migration
  def self.up
    create_table :big_brother_tracks do |t|
      t.column :user_id, :integer
      t.column :user_login, :string
      t.column :ip, :string      
      t.column :controller, :string
      t.column :action, :string
      t.column :method, :string
      t.column :ajax, :boolean
      t.column :entry, :string
      t.column :language, :string
      t.column :created_at, :datetime
    end
  end

  def self.down
    drop_table :big_brother_tracks
  end
end
