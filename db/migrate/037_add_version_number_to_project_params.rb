class AddVersionNumberToProjectParams < ActiveRecord::Migration
  def self.up
    add_column :project_params, :current_version_number, :integer, :null => false, :default => 2, :limit => 3
  end

  def self.down
    remove_column :project_params, :current_version_number
  end
end
