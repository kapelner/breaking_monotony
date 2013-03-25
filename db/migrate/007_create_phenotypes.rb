class CreatePhenotypes < ActiveRecord::Migration
  def self.up
    create_table :phenotypes do |t|
      t.string :name
      t.integer :hit_id
      
      #for attachment fu:
      t.string :content_type
      t.string :filename
      t.integer :size
      #for attachment fu's image processor
      t.integer :width
      t.integer :height
      
      t.timestamps
    end
  end

  def self.down
    drop_table :phenotypes
  end
end
