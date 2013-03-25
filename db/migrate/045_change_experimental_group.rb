class ChangeExperimentalGroup < ActiveRecord::Migration
  def self.up
    remove_column :workers, :experimental_group
    add_column :workers, :experimental_group, :string
  end

  def self.down
    remove_column :workers, :experimental_group
    add_column :workers, :experimental_group, :boolean
  end
end
