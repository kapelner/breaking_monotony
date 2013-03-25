class AdminController < ApplicationController
  include BmomMTurk
  
  before_filter :super_user_required

  def nuke
    if Rails.env.development?
      MHit.destroy_all
      Worker.destroy_all
      MHitView.destroy_all
      PaymentOutcome.destroy_all
      ColorBlindnessTest.destroy_all
      VideoWatching.destroy_all
      Qualification.destroy_all
      Identification.destroy_all
      BigBrotherTrack.destroy_all
      BigBrotherParam.destroy_all
      flash[:notice] = 'DB nuked'
      redirect_to :action => :index
    else
      render :text => 'You cannot nuke the db on production'
    end
  end

  ADAM_WORKER_ID = '<anonymized>'
  DANA_WORKER_ID = '<anonymized>'
  def nuke_adam_and_dana
    adam = Worker.find_by_mturk_worker_id(ADAM_WORKER_ID)
    dana = Worker.find_by_mturk_worker_id(DANA_WORKER_ID)
    flash[:notice] = (adam.nil? ? '' : 'Nuked Adam. ') + (dana.nil? ? '' : 'Nuked Dana. ') + ((adam.nil? and dana.nil?) ? 'Neither Adam nor Dana were in the database.' : '')
    adam.destroy if adam
    dana.destroy if dana
    redirect_to :action => :index
  end
  
  def index
    @title = 'Control Panel'
    @phenotypes = Phenotype.all
    @images = Image.all
    @workers = Worker.includes(:m_hit).select{|w| !w.m_hit.nil? and w.time_spent_watching_video > 0 or w.wanted_to_leave?}
  end

  def update_version_number
    ProjectParam.getvals.current_version_number = params[:n]
    ProjectParam.getvals.save!
    redirect_to :action => :index
  end

  def dashboard
    @title = 'Dashboard'
    @ddws = DisqualifyDataFromWorker.all.map{|ddw| ddw.mturk_worker_id}
  end

  def worker_comments
    @title = 'Worker Comments'
    @surveys = WorkerSurvey.all
  end

  def raw_data_dump    
    response.headers['Cache-Control'] = 'max-age=30, must-revalidate'
    #the worker loading goes on inside the
    send_file DataDump.dump,
      :type => 'text/plain', :disposition => 'attachment'
  end

  def display_training_images
    @images = Image.find(:all, :include => [:phenotype, :identifications])
    render :partial => 'display_training_images'
  end

  def add_phenotype
    return unless request.post?
    p = Phenotype.new
    if Phenotype.find_by_name(params[:name])
      flash[:error] = "There already exists a phenotype with this name"
      return
    end
    p.name = params[:name]
    p.phenotype = params[:file]
    p.width = params[:width]
    p.height = params[:height]
    flash[:notice] = %Q|Could not upload phenotype "#{p.name}"| unless p.save
    redirect_to :action => :index
  end

  def delete_phenotype
    Phenotype.find_by_encrypted_id(params[:id]).destroy
    redirect_to :action => :index
  end

  #adds image then creates the hit
  def add_image
    return unless request.post?
    if params[:phenotype_id].blank?
      flash[:error] = "You need to choose a phenotype for this training image"
      redirect_to :action => :index
      return
    end
    if params[:file].blank?
      flash[:error] = "You need to choose an image file"
      redirect_to :action => :index
      return
    end
    if params[:width].blank? or params[:height].blank?
      flash[:error] = "You need enter the image dimensions properly"
      redirect_to :action => :index
      return
    end
    image = Image.new
    image.phenotype = Phenotype.find(params[:phenotype_id]) #nab the problem here and don't wait for it to get worse
    image.image = params[:file]
    image.width = params[:width]
    image.height = params[:height]
    image.save!
#    flash[:notice] = %Q|Could not upload image "#{image.image_identifier}"|

    redirect_to :action => :index
  end

  def change_image_order
    img = Image.find_by_encrypted_id(params[:id])
    img.order = params[:order]
    img.save!
    render :text => img.order.blank? ? "Image removed from experiment" : "Image order changed to #{img.order}"
  end

  def change_num_images_in_experiment
    ProjectParam.getvals.update_attributes(:num_images => params[:n])
    render :text => "Num images in experiment updated to #{params[:n]}"
  end

  def update_consistency_message
    render :text => Image.consistent_set_message
  end

  def delete_image
    Image.find_by_encrypted_id(params[:id]).destroy
    redirect_to :action => :index
  end

  def create_hits
    if (params[:n_US].blank? or params[:n_US].to_i <= 0) and (params[:n_IN].blank? or params[:n_IN].to_i <= 0)
      flash[:error] = "You must enter an integer number greater than 0"
    elsif Image.consistent_set_message != Image::CONSISTENT_MESSAGE
      flash[:error] = "Image set inconsistent, HITs cannot be created: #{Image.consistent_set_message}"
    else #we made it, create the HITs
      
      (params[:n_US].to_i).times{MHit.create_new_hit_on_mturk(MHit::USA)} unless params[:n_US].blank?
      (params[:n_IN].to_i).times{MHit.create_new_hit_on_mturk(MHit::INDIA)} unless params[:n_IN].blank?
    end    
    redirect_to :action => :index
  end

  def investigate_worker
    @title = "IW #{params[:id]}"
    #3 ways to find workers, don't care which one pans out
    @worker = Worker.find_by_id(params[:id], :include => [:payment_outcome, :color_blindness_test, :video_watchings, :qualification, :identifications])
    @worker = Worker.find_by_mturk_worker_id(params[:id], :include => [:payment_outcome, :color_blindness_test, :video_watchings, :qualification, :identifications]) if @worker.nil?
    @worker = Worker.find_by_ip_address(params[:id].gsub("-", "."), :include => [:payment_outcome, :color_blindness_test, :video_watchings, :qualification, :identifications]) if @worker.nil?
    @disqualification = DisqualifyDataFromWorker.find_by_mturk_worker_id(@worker.mturk_worker_id)
    @comments = WorkerAdminComment.find_all_by_worker_id(@worker.id, :include => :user)
    @m_hit_views = MHitView.find_all_by_ip_address(@worker.ip_address)
    @google_visualization = true
  end

  def mark_worker_as_manually_checked
    Worker.find_by_id(params[:worker_id]).update_attributes(:manually_checked_over => params[:checked] == 'true' ? Time.now : nil)
    render :nothing => true
  end

  def investigate_worker_tracks
    @worker = Worker.find(params[:id])
    render :partial => 'worker_tracking'
  end

  def hit_log
    @title = "Log #{params[:id]}"
    @identification = Identification.find(params[:id], :include => :image)
    @log_entries = @identification.log.sort{|a, b| b[2] <=> a[2]}
    @log_summary = @log_entries.map{|l| l.first}.inject({}) do |hash, a|
      hash[a] ||= 0
      hash[a] += 1
      hash
    end.sort{|a, b| b.last <=> a.last} #descending order for n=
  end

  def accuracy_statistics
    @title = "AS #{params[:id]}"
    @identification = Identification.find(params[:id], :include => [:image, {:worker => [:m_hit, :color_blindness_test]}])
  end

  def dispose_identification
    begin
      Identification.find(params[:id]).destroy
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Hit #{params[:id]} not found"
    end
    if params[:worker_id]
      redirect_to :action => :investigate_worker, :id => params[:worker_id]
    else
      redirect_to :action => :index
    end
  end

  def dispose_hit
    begin
      hit = MHit.find_by_encrypted_id(params[:id])
      hit.destroy
      delete_hit_on_mturk(hit.mturk_hit_id)      
    rescue
      flash[:error] = "This HIT was not deleted on MTurk because it was either invalid or someone is viewing / working on it, but it was deleted in the local database"
    end
    redirect_to :action => :index
  end

  def approve_or_reject_hits
    CronJob.run(:approve_or_reject_hits)
    redirect_to :action => :cron_jobs
  end

  def investigate_all_workers
    @title = 'All workers'
    @workers = Worker.all.select{|w| [6, 7].include?(w.got_up_to)}
    if @workers.empty?
      flash[:error] = "There are no workers to investigate."
      redirect_to :action => :index
    end
    @disqualified_ids_hash = DisqualifyDataFromWorker.find(:all).inject({}){|hash, ddw| hash[ddw.mturk_worker_id] = true; hash}
    @google_visualization = true
  end
  
  def send_emails_to_workers
    workers = params[:worker_ids].split(',')
    bad_ids = []
    workers.each do |w|
      begin
        mturk_send_emails(params[:subject], params[:body] + "     " + w, [w])
      rescue
        bad_ids << w
      end
    end
    flash[:bad_ids] = bad_ids
    render :text => "#{workers.length - bad_ids.length} emails sent! #{bad_ids.empty? ? '' : 'Errors: ' + bad_ids.join(', ')}"
  end

  def investigate_all_inaccurate_hits
    @title = 'Inaccurate trainings'
    @inaccurate_hits = Identification.find(:all, :include => {:worker => :m_hit}).select{|i| i.worker.m_hit and i.worker.m_hit.admin_view? and i.done? and i.not_accurate_enough?}
    if @inaccurate_hits.empty?
      flash[:notice] = 'All HITs are accurate or there are no HITs completed.'
      redirect_to :action => :index
    end
  end

  def cron_jobs
    @title = 'Cron Jobs'
    @cron_jobs = CronJob.find(:all)
    if @cron_jobs.empty?
      flash[:notice] = 'No cron jobs yet.'
      redirect_to :action => :index
    end
    @cron_jobs = @cron_jobs.select{|cj| cj.name == params[:job]} if params[:job]
  end

  def disqualified_data_from_workers
    @title = 'Disqualified Data by Worker'
    @ddws = DisqualifyDataFromWorker.find(:all, :include => :user)
  end

  def delete_disqualified_data_from_worker
    ddw = DisqualifyDataFromWorker.find(params[:id])
    ddw.destroy
    redirect_to :action => :investigate_worker, :id => ddw.mturk_worker_id, :blind => true
  end

  def create_disqualified_data_from_worker
    begin
      DisqualifyDataFromWorker.create(params[:disqualified_data_from_worker].merge(:user => self.current_user))
    rescue
      flash[:error] = 'Error disqualifying this worker. Ensure you fill out all the fields.'
    end
    redirect_to :action => :investigate_worker, :id => params[:disqualified_data_from_worker][:mturk_worker_id], :blind => true
  end

  def create_worker_comment
    WorkerAdminComment.create({
      :body => params[:body],
      :worker_id => params[:worker_id],
      :user => self.current_user
    })
    redirect_to :action => :investigate_worker, :id => params[:worker_id], :blind => true
  end

end

module PhenotypeUploadMethods
  attr_accessor :phenotype_name
  def filename
    "#{self.phenotype_name}.jpg"
  end
  def original_filename
    "#{self.phenotype_name}.jpg"
  end
end
