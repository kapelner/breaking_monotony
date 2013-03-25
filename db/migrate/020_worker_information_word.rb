 class WorkerInformationWord < ActiveRecord::Migration
  def self.up
    add_column :worker_informations, :word, :string
  end

  def self.down
    remove_column :worker_informations, :word
  end
end
