class FilesController < ApplicationController

  FlowPlayerVer = '3.2.7'
  
  def get_phenotype_image
    phenotype = Phenotype.find_by_encrypted_id(params[:id])
    render :nothing => true and return unless phenotype
    send_file "#{Rails.root}/phenotype_icons/#{phenotype[:phenotype]}",
      :disposition => 'inline', 
      :type => 'image/jpeg'
  end

  
  def get_training_image
    image = Image.find_by_encrypted_id(params[:id])
    render :nothing => true and return unless image
    send_file "#{Rails.root}/images_for_labeling/#{image[:image]}",
      :disposition => 'inline', 
      :type => 'image/jpeg'
  end
end
