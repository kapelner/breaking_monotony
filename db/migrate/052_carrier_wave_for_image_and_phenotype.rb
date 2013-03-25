class CarrierWaveForImageAndPhenotype < ActiveRecord::Migration
  def up
    add_column :images, :image, :string
    add_column :phenotypes, :phenotype, :string
  end

  def down
    remove_column :images, :image
    remove_column :phenotypes, :phenotype
  end
end
