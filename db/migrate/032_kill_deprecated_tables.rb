class KillDeprecatedTables < ActiveRecord::Migration
  def self.up
    drop_table :hits
    drop_table :hit_acceptances
    drop_table :hit_viewings
    drop_table :qualified_workers
    drop_table :video_viewings
    drop_table :worker_informations
  end

  def self.down
    #no way down...
  end
end
