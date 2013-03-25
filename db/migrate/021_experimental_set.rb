class ExperimentalSet < ActiveRecord::Migration
  def self.up
#    add_column :hits, :experimental_set, :integer
#    Hit.find(:all).each{|h| h.experimental_set = 1; h.save!}
  end

  def self.down
#    remove_column :hits, :experimental_set
  end
end
