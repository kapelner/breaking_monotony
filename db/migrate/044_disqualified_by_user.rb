class DisqualifiedByUser < ActiveRecord::Migration
  def self.up
    add_column :disqualify_data_from_workers, :user_id, :integer
    DisqualifyDataFromWorker.find(:all).each{|ddfw| ddfw.update_attributes(:user => User.find(:first))}
  end

  def self.down
    remove_column :disqualify_data_from_workers, :user_id
  end
end
