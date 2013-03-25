=begin
The MIT License

Copyright (c) 2010 Adam Kapelner and Dana Chandler

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
=end

require 'rturk'

#a fairly simple wrapper around the ruby aws interface
module RTurkWrapper
  
  #Where is the server?
  SERVER = Rails.env.development? ? PersonalInformation::DevServer : PersonalInformation::ProdServer

  #create the connection immediately
  RTurk.setup(PersonalInformation::AwsAccessKeyID, PersonalInformation::AwsSecretKey, :sandbox => Rails.env.development?)
  RTurk::logger.level = Logger::DEBUG if Rails.env.development?
  
  #other constants that are useful
  PreviewAssignmentId = 'ASSIGNMENT_ID_NOT_AVAILABLE'
  
  def mturk_create_hit(options = {})
    #error handling
    raise "no title given for HIT" unless options[:title]
    raise "no description given for HIT" unless options[:description]
    raise "no keywords given for HIT" unless options[:keywords]
    raise "no duration given for HIT" unless options[:assignment_duration]
    raise "no auto-approval time given for HIT" unless options[:assignment_auto_approval]
    raise "no wage given for HIT" unless options[:wage]
    raise "no frame height given for HIT" unless options[:frame_height]
    raise "no render URL given for HIT" unless options[:render_url]
    
    # Creating the HIT and loading it into Mechanical Turk, returns it as an object as well
    RTurk::Hit.create(:title => options[:title]) do |hit|
      hit.description = options[:description]
      hit.assignments = 1 #one assignment per created HIT ALWAYS
      hit.question("http://#{SERVER}#{options[:render_url]}", :frame_height => options[:frame_height])
      hit.reward = options[:wage]
      hit.lifetime = options[:lifetime]
      hit.keywords = options[:keywords]
      hit.duration = options[:assignment_duration]
      hit.qualifications.add :country, {:eql => options[:country]}
      hit.auto_approval = options[:assignment_auto_approval]
    end
  end

  #other things to set
  DefaultAcceptanceMessage = 'Thanks for a job well done!'
  DefaultBonusMessage = 'Thanks for a superb job!'
  DefaultRejectionFeedback = "Sorry, you did not take our task seriously."
  
  def mturk_approve_assignment(assignment_id, feedback = DefaultAcceptanceMessage)
    RTurk::ApproveAssignment(:assignment_id => assignment_id, :feedback => feedback)
  end

  def mturk_reject_assignment(assignment_id, feedback = DefaultRejectionFeedback)
    RTurk::RejectAssignment(:assignment_id => assignment_id, :feedback => feedback)
  end

  def mturk_bonus_assignment(assignment_id, worker_id, bonus, feedback = DefaultBonusMessage)
    RTurk::GrantBonus(:assignment_id => assignment_id, :worker_id => worker_id, :amount => bonus, :feedback => feedback)
  end

  def delete_hit_on_mturk(hit_id)
    RTurk::DisableHIT(:hit_id => hit_id)
  end

  def dispose_hit_on_mturk(hit_id)
    RTurk::DisposeHIT(:hit_id => hit_id)
  end

  def mturk_send_emails(subject, body, worker_ids)
    RTurk::NotifyWorkers.create({
      :subject => subject,
      :message_text => body,
      :worker_ids => worker_ids
    })
  end
 
end