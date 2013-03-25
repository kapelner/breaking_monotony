class CreateProjectParams < ActiveRecord::Migration
  def self.up
    create_table :project_params do |t|
      t.integer :num_images, :limit => 2
      t.timestamps
    end
    ProjectParam.create(:num_images => 5)
  end

  def self.down
    drop_table :project_params
  end
end
