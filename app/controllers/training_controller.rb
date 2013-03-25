class TrainingController < ApplicationController
  include BmomMTurk
  
  CanvasHeight = 400
  ThumbnailWidth = 75

  PreviewAssignmentId = 'ASSIGNMENT_ID_NOT_AVAILABLE'
  
  def index
    @mhit = MHit.find_by_encrypted_id(params[:hit_id], :include => :workers)

    #handle worker if they are merely previewing the page...
    if params[:assignmentId] == PreviewAssignmentId
      hv = MHitView.create(:ip_address => request.remote_ip, :m_hit => @mhit)
      raise "hit view not created" if hv.nil?
      render :action => 'splash_screen', :layout => 'training'
      return
    end

    #WORKER HAS ACCEPTED AT THIS POINT
    #make sure worker has not accepted a previous HIT
    previous_worker_entries = Worker.find_all_by_mturk_worker_id(params[:workerId])
    if previous_worker_entries.detect{|w| w.m_hit_id != @mhit.id} or DisqualifiedWorker.find_by_mturk_worker_id(params[:workerId])
      redirect_to :action => 'accepted_another_hit_before'
      return
    end

    #this worker has not worked before, create him
    @worker_for_this_hit = previous_worker_entries.detect{|w| w.m_hit_id == @mhit.id}
    if @worker_for_this_hit.nil?
      #this hit's experimental condition must be randomized
      @mhit.current_mturk_worker_id = params[:workerId]
      @mhit.save!
      # record this acceptance, so we don't do it again
      
      @worker_for_this_hit = Worker.create({ #only create this once
        :m_hit => @mhit,
        :mturk_worker_id => params[:workerId],
        :mturk_assignment_id => params[:assignmentId],
        :experimental_group => MHit.randomize_experimental_group,
        :image_order => Image.all_training_image_ids_randomized,
        :ip_address => request.remote_ip
      })
    end
    
    #I have no idea why I get less bugs with Amazon if I do this...
    @worker_for_this_hit.update_attributes(:mturk_assignment_id => params[:assignmentId])

    #did they already do the colorblindness test?
    if @worker_for_this_hit.blindness_test_not_taken?
      redirect_to :action => :information_screen, :workerId => params[:workerId], :assignmentId => params[:assignmentId], :worker_id => @worker_for_this_hit.id, :hit_id => params[:hit_id]
      return
    end

    if @worker_for_this_hit.color_blindness_test.colorblind? #if the user is colorblind, he cannot participate in our study
      redirect_to :action => :colorblind
      return
    end

    if @worker_for_this_hit.color_blindness_test.too_young_or_too_old?
      redirect_to :action => :wrong_age
      return
    end

    if @worker_for_this_hit.shredded? and @worker_for_this_hit.has_not_seen_warning_page?
      redirect_to :action => :warning_message, :worker_id => @worker_for_this_hit.id
      return
    end

    if @worker_for_this_hit.unqualified?
      redirect_to :action => :video_and_qualification_test, :worker_id => @worker_for_this_hit.id
      return
    end

    #now check if the user has pressed submit before, if so, show him an already done
    #page and give him the chance to try and submit once again
    if @worker_for_this_hit.pushed_submit_to_mturk?
      redirect_to :action => 'already_pressed_submit_try_again', :worker_id => @worker_for_this_hit.id
      return
    end

    #now check if the user finished and went on to the survey
    if @worker_for_this_hit.worker_survey
      redirect_to :action => :survey, :id => @worker_for_this_hit.id
      return
    end

    #now try to find current identification or just create one:
    @identification = @worker_for_this_hit.current_identification || @worker_for_this_hit.create_new_identification
    #if this idenitification has not started, start it up now...
    @identification.update_attributes(:started_at => Time.now) if @identification.started_at.nil?

    render :layout => 'training'
  end

  def already_pressed_submit_try_again
    @do_not_show_confirm_message = true
    @worker_for_this_hit = Worker.find(params[:worker_id])
  end

  def acknowledge_work_not_counted
    @worker_for_this_hit = Worker.find(params[:worker_id])
    @worker_for_this_hit.update_attributes(:warning_page_seen => true)
    redirect_to :action => :index, 
      :id => @worker_for_this_hit.id,
      :assignmentId => @worker_for_this_hit.mturk_assignment_id,
      :workerId => @worker_for_this_hit.mturk_worker_id,
      :hit_id => @worker_for_this_hit.m_hit.encrypted_id
  end

  def video_and_qualification_test
    @worker_for_this_hit = Worker.find(params[:worker_id])
  end

  def trouble_viewing_image_button
    redirect_to :action => :index, :hit_id => params[:hit_id], :workerId => params[:workerId], :assignmentId => params[:assignmentId]
  end

  def train_another_image_button
    redirect_to :action => :index, :hit_id => params[:hit_id], :workerId => params[:workerId], :assignmentId => params[:assignmentId]
  end

  def task_expired
    @do_not_show_confirm_message = true
    @worker_for_this_hit = Worker.find(params[:id], :include => :identifications)
    render :action => :finished
  end

  def not_accurate_enough_reject
    @do_not_show_confirm_message = true
    @worker_for_this_hit = Worker.find(params[:id], :include => :identifications)
    render :action => :finished
  end

  def information_screen
    @worker = Worker.find(params[:worker_id])
    if request.post?
      begin
        @wi = ColorBlindnessTest.create(params[:color_blindness_test])
      rescue ActiveRecord::StatementInvalid
        flash[:error] = 'You have already answered these questions.'
        redirect_to :action => :index, :workerId => params[:workerId], :hit_id => params[:hit_id], :assignmentId => params[:assignmentId]
        return
      end
      if @wi.valid?
        #duplicate a request from MTurk with all three essential paramters
        redirect_to :action => :index, :workerId => params[:workerId], :hit_id => params[:hit_id], :assignmentId => params[:assignmentId]
      end
    end
  end

  def submit_points_for_one_identification
    @identification = Identification.find_by_encrypted_id(params[:enc_identification_id], :include => {:worker => :m_hit})
    #sanity checks
    raise "invalid identificaion" if @identification.nil?
    raise "no one qualified for this hit" if @identification.worker.unqualified?
    #now save data
    @identification.parse_points(params[:points])
    @identification.parse_log(params[:log])
    @identification.calculate_accuracy
    @identification.submitted_at = Time.now #thereby marking this hit "done"
    @identification.save!
    
    #conveniences for using multiple render partials:
    @worker_for_this_hit = @identification.worker
    @mhit = @worker_for_this_hit.m_hit
    if @worker_for_this_hit.identifications.select{|i| i.not_accurate_enough?}.length >= 3
      redirect_to :action => :not_accurate_enough_reject, :id => @worker_for_this_hit.id
    else
      @worker_for_this_hit.create_new_identification #create a new HIT immediately so countdown starts going!
      @identification = @worker_for_this_hit.current_identification #update the identification var with the new one
      render :action => 'finished_and_offer_new_hit'
    end
  end

  def submit_to_mturk_and_close_session
    worker = Worker.find_by_encrypted_id(params[:enc_worker_id])
    worker.finished_at = Time.now
    worker.save!
    render :nothing => true
  end

  def update_log
    begin
      @identificaion = Identification.find_by_encrypted_id(params[:enc_identification_id])
      @identificaion.parse_log(params[:log])
      @identificaion.save!
      render :nothing => true
    rescue
      render :text => 'an error has occured'
    end
  end
  
  def qualification_test
    render :partial => 'qualification_test', :layout => 'training'
  end
  
  def add_qualified_worker
    return unless request.post?
    worker = Worker.find(params[:worker_id])
    begin
      Qualification.create(:worker => worker)
    rescue ActiveRecord::StatementInvalid
    end
    render :nothing => true
  end

  def warning_message
    @want_to_leave = WantToLeave.find_by_worker_id(params[:worker_id])
  end

  def worker_wants_to_leave
    WantToLeave.create(:worker_id => params[:worker_id])
    render :nothing => true
  end

  def log_video_event
    return unless request.post?
    VideoWatching.create(:worker_id => params[:worker_id], :elapsed => params[:elapsed], :event_type => params[:event_type])
    render :nothing => true
  end

  def help
    render :layout => 'application'
  end

  def survey
    @worker_for_this_hit = Worker.find(params[:id])
    #load up the one in the db or create a new one
    @survey = @worker_for_this_hit.worker_survey || WorkerSurvey.create(:worker_id => @worker_for_this_hit.id)
    if request.post?
      #record the results of the survey
      @survey.update_attributes({
        :enjoyment => params[:enjoyment],
        :purpose => params[:purpose],
        :accomplishment => params[:accomplishment],
        :meaningful => params[:meaningful],
        :recognition => params[:recognition],
        :comments => params[:comments],
        :finished_at => Time.now
      })
      #render finished page so they can FINALLY submit...
      render :action => :finished
    end
  end
end
