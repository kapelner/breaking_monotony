require 'carrierwave/orm/activerecord'

class Phenotype < ActiveRecord::Base
  include EncryptionTools
  
  has_many :images

  mount_uploader :phenotype, PhenotypeUploader
 
  validates :name, :presence => true
  
  DisplayFactor = 0.5
  def display_width
    self.width * DisplayFactor
  end
  
  def display_height
    self.height * DisplayFactor
  end
  
  DisplayMagnifiedFactor = 2
  def magnified_width
    self.width * DisplayMagnifiedFactor
  end
  
  def magnified_height
    self.height * DisplayMagnifiedFactor
  end
  
  NON_NAME = 'NON'
  def is_non?
    self.name == NON_NAME
  end
end