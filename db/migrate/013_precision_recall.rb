class PrecisionRecall < ActiveRecord::Migration
  def self.up
    remove_column :hits, :accuracy
    add_column :hits, :precision, :float
    add_column :hits, :recall, :float
  end

  def self.down
    add_column :hits, :accuracy, :float
    remove_column :hits, :precision, :float
    remove_column :hits, :recall, :float
  end
end
