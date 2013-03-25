class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|     
      #for attachment fu:
      t.string :content_type
      t.string :filename
      t.integer :size
      #for attachment fu's image processor
      t.integer :width
      t.integer :height

      #for us:
      t.integer :phenotype_id
      t.integer :order, :limit => 3
      t.text :truth_points
      
      t.datetime :created_at
    end

    add_index :images, :order
  end

  def self.down
    drop_table :images
  end
end
