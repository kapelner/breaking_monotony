class CreateWorkerSurveys < ActiveRecord::Migration
  def change
    create_table :worker_surveys do |t|
      t.integer :worker_id
      t.integer :enjoyment, :limit => 1
      t.integer :purpose, :limit => 1
      t.integer :accomplishment, :limit => 1
      t.integer :meaningful, :limit => 1
      t.integer :recognition, :limit => 1
      t.text :comments
      t.datetime :finished_at
      t.datetime :created_at
    end
  end
end
