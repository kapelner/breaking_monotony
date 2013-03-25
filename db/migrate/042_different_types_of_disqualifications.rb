class DifferentTypesOfDisqualifications < ActiveRecord::Migration
  def self.up
    add_column :disqualify_data_from_workers, :level, :integer, :limit => 1, :default => 1
    add_column :disqualify_data_from_workers, :error_code, :string
  end

  def self.down
    remove_column :disqualify_data_from_workers, :level
    remove_column :disqualify_data_from_workers, :error_code
  end
end
