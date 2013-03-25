class WorkerSurvey < ActiveRecord::Base
  belongs_to :worker

  def filled_in?
    !self.finished_at.nil?
  end

  def time_taken
    filled_in? ? self.finished_at - self.created_at : nil
  end

  def dump_comments
    self.comments.nil? ? '' : self.comments.gsub(',', '+')
  end

  def num_words_in_comments
    self.comments.nil? ? 0 : self.comments.split(/\s/).length
  end

  def WorkerSurvey.dump
    t = Time.now
    filename = "#{Rails.root}/bmom_survey_dump_#{t.strftime('%m_%d_%y__%H_%M')}.txt"
    write_out = File.new(filename, "w")
    row = 'trt,country,time_taken,num_images,enjoyment,purpose,accomplishment,meaningful,recognition,comments'
    write_out.puts(row)
    WorkerSurvey.find_each do |survey|
      data = []
      data << survey.worker.experimental_group
      data << survey.worker.m_hit.experimental_country_to_text
      data << (survey.time_taken.nil? ? -99 : ('%.0f' % survey.time_taken))
      data << survey.worker.all_done_identifications.length
      data << survey.enjoyment
      data << survey.purpose
      data << survey.accomplishment
      data << survey.meaningful
      data << survey.recognition
      data << survey.dump_comments
      write_out.puts(data.join(','))
    end
    write_out.close
    filename
  end
end
