module DataDump

  SeparationChar = ','
  StrftimeForDates = '%m/%d/%y'
  StrftimeForTimes = '%H:%M:%S'

  #note we have to make it work using find_each
  def DataDump.dump
    disqualified_ids_hash = DisqualifyDataFromWorker.find(:all).inject({}){|hash, ddw| hash[ddw.mturk_worker_id] = true; hash}
    
    #create file and the first row
    t = Time.now
    filename = "#{Rails.root}/bmom_dump_#{t.strftime('%m_%d_%y__%H_%M')}.txt"
    write_out = File.new(filename, "w")
    row = 'Disqualified,WID,Time_of_acceptance,Mturk_ID,Version,Country,Treatment,Gender,Age,Up_to,Want_to_leave_time,Time_to_qualify_sec,Longest_elapsed_time_watching_video,Finished_video,Admin_Comments,Survey_started_at,time_taken_for_survey,enjoyment_level,purpose_level,accomplishment_level,meaningful_level,recognition_level,Wage,Quality_Acceptable_To_Continue,Image_name,Img_Order,Num_Points,Training_Duration_in_s,Longest_Break_in_s,Used_Increase_Magnification_In_Beginning,Used_Decrease_Magnification_At_End,Num_Zooms,Num_Zooms_Per_Training_Pt,Num_Pt_Deletions,Local_time_of_Task_acceptance,Date_of_Task_acceptance,Qual_F_1,Qual_Rec_1,Qual_F_2,Qual_Rec_2,Qual_F_3,Qual_Rec_3,Qual_F_4,Qual_Rec_4,Qual_F_5,Qual_Rec_5,Qual_F_10,Qual_Rec_10,Qual_Sum_Of_Squared_Distances,Qual_Sum_Of_Absolute_Distance,Qual_Avg_Distance'
    write_out.puts(row)

    Worker.find_each(:batch_size => 50, :include => [:m_hit, :color_blindness_test, :video_watchings, :qualification, :want_to_leave, :worker_admin_comments, :worker_survey, {:identifications => {:image => :phenotype}}]) do |w|
      next if w.m_hit.nil?
      disq = disqualified_ids_hash[w.mturk_worker_id].nil? ? 0 : 1
      row = "#{disq},#{DataDump.dump_worker_data(w)}"
      write_out.puts(row)
      w.all_done_identifications.each do |i|        
        row = "#{disq},#{DataDump.dump_worker_data(w)},#{DataDump.dump_identification_data(i, w.m_hit)}"
        write_out.puts(row)
      end
    end

    write_out.close
    filename
  end

  def DataDump.dump_worker_data(w)
    str = []
    str << w.id
    str << MHit.t_str(w.created_at, w.m_hit)
    str << w.mturk_worker_id
    str << w.m_hit.version_number
    str << w.m_hit.experimental_country_to_text
    str << w.experimental_group_to_stat_code
    str << (w.color_blindness_test ? w.color_blindness_test.male_female_string : '')
    str << (w.color_blindness_test ? w.color_blindness_test.age : '')
    str << w.quot_got_up_to_quot_str
    str << (w.want_to_leave ? MHit.t_str(w.want_to_leave.created_at, w.m_hit) : '')
    str << (w.qualification ? w.training_time_sec : '')
    str << w.longest_time_watching_video
    str << (w.watched_video? ? 1 : 0)
    str << w.dump_admin_comments
    survey = w.worker_survey
    str << (survey.nil? ? '' : MHit.t_str(survey.created_at, w.m_hit))
    str << (survey.nil? ? '' : survey.time_taken)
    str << (survey.nil? ? '' : survey.enjoyment)
    str << (survey.nil? ? '' : survey.purpose)
    str << (survey.nil? ? '' : survey.accomplishment)
    str << (survey.nil? ? '' : survey.meaningful)
    str << (survey.nil? ? '' : survey.recognition)
    str.join(',')
  end

  def DataDump.dump_identification_data(i, h) #time worked on, time of longest gap, did they use mag cocrrectly?
    str = []
    str << i.wage
    str << (i.accurate_enough? ? 1 : 0)
    str << i.image.filename
    str << i.set_number
    str << i.num_points
    str << i.duration
    str << i.longest_break
    str << (i.used_magnification_in_the_beginning_wisely? ? 1 : 0)
    str << (i.used_magnification_at_the_end_wisely? ? 1 : 0)
    str << i.num_zooms
    str << i.num_zooms_per_training_pt_to_s
    str << i.num_points_deleted
    str << MHit.t_str(i.submitted_at, h, '%H:%S')
    str << MHit.t_str(i.submitted_at, h, '%m-%d')
    [1, 2, 3, 4, 5, 10].each do |r|
      i.calculate_accuracy(r)
      str << ('%.2f' % (i.f_measure * 100))
      str << ('%.2f' % (i.recall * 100))
    end
    str << ('%.0f' % i.sum_of_sqd_distances) #Sum_Of_Squared_Distances,Sum_Of_Absolute_Distance
    str << ('%.0f' % i.sum_of_distances)
    str << ('%.2f' % i.avg_distance)
    str.join(',')
  end
    
end
