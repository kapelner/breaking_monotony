class Worker < ActiveRecord::Base
  include EncryptionTools
  extend BmomMTurk

  belongs_to :m_hit
  has_one :color_blindness_test, :dependent => :destroy
  has_many :video_watchings, :dependent => :destroy
  has_one :qualification, :dependent => :destroy
  has_one :payment_outcome, :dependent => :destroy
  has_many :identifications, :dependent => :destroy
  has_many :worker_admin_comments, :dependent => :destroy
  has_one :want_to_leave, :dependent => :destroy
  has_one :worker_survey, :dependent => :destroy

  serialize :image_order
   
  validates :m_hit_id, :presence => true
  validates :mturk_worker_id, :presence => true
  validates :mturk_assignment_id, :presence => true
  validates :experimental_group, :presence => true
  validates :ip_address, :presence => true
  validates :image_order, :presence => true

  def meaningful?
    self.experimental_group == "meaningful"
  end

  def zero_context?
    self.experimental_group == "zero_context"
  end

  def shredded?
    self.experimental_group == "shredded"
  end

  def experimental_group_to_stat_code
    if self.meaningful?
      "M"
    elsif self.zero_context?
      "L"
    elsif self.shredded?
      "S"
    end
  end

  def has_not_seen_warning_page?
    !self.warning_page_seen?
  end

  def current_identification
    self.reload.identifications.detect{|i| !i.done?}
  end

  def create_new_identification
    n = self.identifications.length
    Identification.create({
      :worker => self,
      :image_id => self.clock_cycle_image(n),
      :wage => self.m_hit.get_wage_for_image_number(n),
      :set_number => n + 1, #we're moving on up
      :started_at => Time.now
    })
  end

  def clock_cycle_image(n)
    self.image_order[n % self.image_order.length] #clock cycle
  end
  
  def total_earnings
    all_done_identifications.inject(0){|sum, i| sum + i.wage}
  end

  def all_done_and_accurate_identifications
    all_done_identifications.reject{|i| i.not_accurate_enough?}
  end

  def all_done_identifications
    self.identifications.select{|i| i.done?}
  end

  def pushed_submit_to_mturk?
    !self.finished_at.nil?
  end

  def blindness_test_not_taken?
    self.color_blindness_test.nil?
  end

  def unqualified?
    self.qualification.nil?
  end
  
  def unpaid?
    self.payment_outcome.nil?
  end

  def training_time_sec
    raise "no qual #{self.id}" if self.qualification.nil?
    self.qualification.created_at - self.created_at
  end

  def training_time_min
    training_time_sec / 60.to_f
  end

  def total_time_sec
    self.all_done_identifications.last.submitted_at - self.created_at
  end

  def total_time_min
    total_time_sec / 60.to_f
  end

  def got_up_to
    quot_got_up_to_quot_str.slice(0, 1).to_i
  end

  def quot_got_up_to_quot_str
    @up_to ||= if self.pushed_submit_to_mturk? and self.finished_at_least_one_task?
                 "9-Qualified_and_submitted_to_MTurk"
               elsif self.finished_at_least_one_task?
                 "8-Qualified_and_finished_at_least_one_task"
               elsif self.started_training?
                 "7-Qualified_and_started_training"
               elsif self.qualification
                 "6-Qualified"
               elsif self.watched_video?
                 "5-Completed_Video"
               elsif self.time_spent_watching_video > 0
                 "4-Started_Video"
               elsif self.wanted_to_leave?
                 "3-Wanted_to_leave"
               elsif self.failed_cb_test?
                 "2-Failed_Color_Blindness_Test"
               elsif self.color_blindness_test
                 "1-Submitted_Color_Blindness_Test"
               else
                 "0-Accepted_HIT"
               end
  end

  def wanted_to_leave?
    !self.want_to_leave.nil?
  end

  def finished_at_least_one_task?
    !self.identifications.empty? and self.identifications.first.done?
  end

  def started_training?
    !self.identifications.empty? and !self.identifications.first.untouched?
  end

  def watched_video?
    !self.video_watchings.detect{|vw| vw.event_type == "finished_video_for_the_first_time"}.nil?
  end

  def longest_time_watching_video
    max_elapsed = -99
    self.video_watchings.each{|vw| max_elapsed = vw.elapsed if vw.elapsed > max_elapsed}
    max_elapsed
  end

  def time_spent_watching_video
    return 0 if self.video_watchings.empty?
    self.video_watchings.last.created_at - self.video_watchings.first.created_at
  end

  def last_action
    if self.finished_at
      self.finished_at
    elsif !self.identifications.empty?
      self.identifications.last.last_action
    elsif self.qualification
      self.qualification.created_at
    elsif !self.video_watchings.empty?
      self.video_watchings.last.created_at
    elsif self.color_blindness_test
      self.color_blindness_test.created_at
    else
      self.created_at
    end
  end

  def time_since_last_action
    '%.1f' % ((Time.now - last_action) / 60.to_f)
  end

  def trackings
    @trackings ||= BigBrotherTrack.find_all_by_ip(self.ip_address, :include => :big_brother_params)
  end

  def dump_admin_comments
    self.worker_admin_comments.inject([]) do |blocks, c|
      blocks << "#{c.body.gsub(',', '+')} -#{c.user.fullname} (#{MHit.t_str(c.created_at, MHit::USA)})"
    end.join('||||')
  end

  def colorblind?
    self.color_blindness_test and self.color_blindness_test.colorblind?
  end

  def too_young_or_too_old?
    self.color_blindness_test and self.color_blindness_test.too_young_or_too_old?
  end

  def failed_cb_test?
    self.colorblind? or self.too_young_or_too_old?
  end

  ### CRON JOBS:
  RejectMessage = 'Your points were not accurate enough'
  def Worker.approve_or_reject_hits
    data = {:payments => [], :accepted => 0, :rejected => 0, :a_or_r_errors => 0, :error_workers => [], :total => 0, :hit_dispose_errors => 0}
    Worker.find(:all, :include => :payment_outcome).select{|w| w.pushed_submit_to_mturk? and w.unpaid?}.each do |w|
      total_earnings = w.total_earnings.round(2) #make sure to round to the nearest cent
      #now for the rejections
      if total_earnings.zero?
        begin
          mturk_reject_assignment(w.mturk_assignment_id, RejectMessage)
          PaymentOutcome.create(:worker => w, :rejected => true, :accepted => false, :total_payout => total_earnings)
          data[:rejected] += 1 #increment num accepted
        rescue
          data[:error_workers] << w.id
          data[:a_or_r_errors] += 1 #increment num accepted
        end
        data[:payments] << 0
      else #ACCEPT!!!
        begin
          bonus = (total_earnings - w.m_hit.initial_wage.to_f).round(2)
          mturk_bonus_assignment(w.mturk_assignment_id, w.mturk_worker_id, bonus) if bonus > 0
          mturk_approve_assignment(w.mturk_assignment_id)
          PaymentOutcome.create(:worker => w, :total_payout => total_earnings)
          data[:accepted] += 1 #increment num accepted
          data[:payments] << total_earnings
        rescue
          data[:a_or_r_errors] += 1 #increment num accepted
          data[:error_workers] << w.id
          data[:payments] << 0
        end
      end
      #now try to delete the HIT:
      begin
        dispose_hit_on_mturk(w.m_hit.mturk_hit_id)
      rescue
        data[:hit_dispose_errors] += 1
      end
      data[:total] += 1 #regardless, bump up total
    end
    data
  end

  def experimental_group_to_debrief_name
    case self.experimental_group
      when "shredded"
        "negative"
      when "zero_context"
        "neutral"
      when "meaningful"
        "treatment"
    end
  end

  def debriefed?
    !self.debriefed_at.nil?
  end

  def Worker.debrief_all_subjects_in_experiment!
    num_debriefed = 0
    errors = []
    Worker.includes(:m_hit).select{|w| !w.m_hit.nil? and w.time_spent_watching_video > 0 or w.wanted_to_leave?}.each do |w|
      next if w.debriefed?
      subject = "Experiment Debriefing: The effect of motivation on Mechanical Turk tasks"
      message =<<ENDL


During the past two weeks, you along with approximately 2,500 other people, completed a task on Mechanical Turk entitled, "Find Objects of Interest in Images (new!) -- $0.10USD + unlimited bonus!!"

This task was actually part of a social science study. We did not mention to you that you were part of a study since it may have invalidated our scientific results and influenced the way you participated in the task. More specifically, we were replicating an experiment by Ariely et al (2008) where they found that workers performed better on identical tasks when those tasks were presented with more context. It is our belief that many requesters on Mechanical Turk do not give users enough context or explanation of the purpose of the task. 

Our experiment consisted of three groups:
1) "treatment group" who were told that was given context for their task and told that they were labeling tumor cells and helping scientists conduct research,
2) "neutral group" who were not given any context for what they were doing and told that they were labeling "objects of interest"
3) "negative group" who were told their work was not kept. Please note that we kept the training points as part of the experimental data for the analysis.

You were part of the: "#{w.experimental_group_to_debrief_name} group."

As a result of our research, we hope to convince requesters on Mechanical Turk (as well as those on other online labor markets) that they should explain the reason for performing tasks and give workers more context. If more requesters adopt this practice, we expect that there will be benefits both to requesters and to you in the long run.

Additionally, the cell-identification task in this HIT used software from the Distributeeyes project of Stanford University (www.distributeeyes.com) whose goal is to employ Turkers to mark real medical images. The data from this study will be used to build the next version of Distributeeyes. Thus, your efforts will indeed help medical researchers.

If you have any questions about this study, please feel free to contact Adam Kapelner and Dana Chandler by using the "requester contact" feature inside MTurk. You may also contact the Institutional Review Board at the University of Pennsylvania by phoning 215-898-2614 (+1 if calling from outside the US).

Thank you for your participation.

References
Ariely, D. and Kamenica, E. and Prelec, D. (2008). "Man's search for meaning: The case of Legos" 67(3-4). 671-677.
ENDL

      
      #send the actual debrief message through MTurk's system (wrap in a begin-rescue in case of crashes)
      begin
        mturk_send_emails(subject, message, [w.mturk_worker_id])
        #mark the worker as debriefed
        w.update_attributes(:debriefed_at => Time.now)
        #print a message about it
        p "worker #{w.id} / #{w.mturk_worker_id} (#{w.experimental_group_to_debrief_name}) was debriefed at #{w.debriefed_at}"
        #update counter
        num_debriefed += 1
      rescue #no idea why...
        errors << w.id
      end
    end
    {:num_debriefed => num_debriefed, :errors => errors}
  end
end
