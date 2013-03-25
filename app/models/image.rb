require 'carrierwave/orm/activerecord'

class Image < ActiveRecord::Base
  include EncryptionTools

  belongs_to :phenotype
  has_many :identifications

  serialize :truth_points

  mount_uploader :image, ImageUploader

  validates :width, :presence => true
  validates :height, :presence => true
  
  ImageThumbDisplayWidth = 150
  def display_width
    ImageThumbDisplayWidth
  end

  def display_height
    self.height * ImageThumbDisplayWidth / self.width
  end

  def Image.all_training_image_ids_randomized
    Image.find(:all).select{|img| img.order}.map{|image| image.id}.sort_by{rand}
  end

  CONSISTENT_MESSAGE = "This image set is consistent and has all images ordered correctly"
  def Image.consistent_set_message(images = Image.find(:all).select{|img| img.order})
    if ProjectParam.getvals.num_images != images.length
      return "Number of experimental images (#{ProjectParam.getvals.num_images}) is not the same as number of ordered images (#{images.length})"
    end
    ProjectParam.getvals.num_images.times do |i|
      return "We are missing an image at order number #{i + 1}" unless images.detect{|img| img.order == i + 1}
    end
    CONSISTENT_MESSAGE
  end

  def Image.carrier_wave_process!
    Image.find_each do |im|
      im[:image] = im.filename
      im.save!
    end
  end
end

=begin
mysql adkdacsl_dev < load_up_images_with_truth_pts.sql -u root -p
=end