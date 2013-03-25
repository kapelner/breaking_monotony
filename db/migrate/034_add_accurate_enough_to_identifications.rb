class AddAccurateEnoughToIdentifications < ActiveRecord::Migration
  def self.up
    add_column :identifications, :accurate_enough, :boolean
  end

  def self.down
    remove_column :identifications, :accurate_enough
  end
end
