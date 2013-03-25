class CreateBigBrotherParams < ActiveRecord::Migration
  def self.up
    create_table :big_brother_params do |t|
      t.column :param, :string
      t.column :value, :text, :limit => 10000
      t.column :big_brother_track_id, :integer      
    end
  end

  def self.down
    drop_table :big_brother_params
  end
end
