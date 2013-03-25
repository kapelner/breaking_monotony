class AddImageOrderToWorker < ActiveRecord::Migration
  def self.up
    add_column :workers, :image_order, :text
  end

  def self.down
    remove_column :workers, :image_order
  end
end
