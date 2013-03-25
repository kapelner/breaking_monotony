class CreateCronJobs < ActiveRecord::Migration
  def self.up
    create_table :cron_jobs do |t|
      t.string :name
      t.text :data
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :cron_jobs
  end
end
