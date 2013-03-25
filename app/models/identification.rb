class Identification < ActiveRecord::Base
  include EncryptionTools
  include QualityAndAccuracyMetricsModule
  
  belongs_to :worker
  belongs_to :image

  serialize :points
  serialize :log

  validates :worker_id, :presence => true
  validates :image_id, :presence => true
  validates :wage, :presence => true
  validates :set_number, :presence => true

  def done?
    !self.submitted_at.nil?
  end

  def first_in_set?
    self.set_number == 1
  end

  def untouched?
    self.log.nil?
  end

  ExpirationTime = 15 * 60 #15 min
  def seconds_left
    ExpirationTime - (Time.now - self.started_at).ceil
  end

  def last_action
    if self.submitted_at
      self.submitted_at
    elsif self.log
      Time.at(self.log.last[2].slice(0...-3).to_i)
    else
      self.created_at
    end
  end
  ############### points stuff
  def download_training_data
    all_data = []
    self.points.each do |phenotype, data|
      all_data << phenotype
      all_data << "-" #one dash separates the phenotype name from the data itself
      all_data << data
      all_data << "::" #two colons separate phenotypes
    end
    all_data.join('')
  end

  def num_points
    @num_points ||= self.points.nil? ? 0 : self.points.values.inject(0){|s, str| s + (str.nil? ? 0 : str.split(';').length)}
  end

  def parse_points(raw)
    data = {} #represent it as a hash from phenotype --> string of x_1,y_1;x_2,y_2;...
    raw.split('|').each do |raw_phenotype|
      name, points = raw_phenotype.split(':')
      data[name] = points
    end
    self.points = data
  end

  def parse_log(raw)
    self.log = raw.split('|').inject([]){|arr, a| arr << a.split(':'); arr}
  end

  def points_as_strings
    self.points.nil? ? '' : self.points[self.image.phenotype.name].nil? ? '' : self.points[self.image.phenotype.name].split(";")
  end

  def log_to_points_as_strings
    self.log.select{|l| l.first == "new_training_point"}.map{|l| l[1]}
  end

  def duration
    return 0 if self.log.nil?
    (self.log.last.last.to_i - self.log.first.last.to_i) / 1000
  end

  def duration_to_s
    "#{'%.1f' % (self.duration / 60.to_f)}"
  end

  def duration_save_longest_break_to_s
    "#{'%.1f' % ((self.duration - self.longest_break) / 60.to_f)}"
  end

  def longest_break
    return 0 if self.log.nil?
    longest_break = 0
    self.log.each_with_index do |l, i|
      next if i == 0
      next if l.first.match(/submit/i)
      delta = l.last.to_i - self.log[i - 1].last.to_i
      longest_break = delta if delta > longest_break
    end
    longest_break / 1000
  end

  def num_points_deleted
    return 0 if self.log.nil?
    num_points_deleted = 0
    self.log.each do |l|
      num_points_deleted += 1 if l.first.match(/delete_training_points/i)
    end
    num_points_deleted
  end

  def num_zooms
    return 0 if self.log.nil?
    num_zooms = 0
    self.log.each do |l|
      num_zooms += 1 if l.first.match(/magnification/i)
    end
    num_zooms
  end

  NumLogPointsToCheckForWisdom = 10
  def used_magnification_in_the_beginning_wisely?
    self.log.each_with_index do |l, i|
      break if i > NumLogPointsToCheckForWisdom
      return true if l.first == 'bump_up_magnification'
    end
    false
  end

  def used_magnification_at_the_end_wisely?
    self.log.reverse.each_with_index do |l, i| #same thing as above, just reverse the array
      break if i >= NumLogPointsToCheckForWisdom
      return true if l.first == 'bump_down_magnification'
    end
    false
  end

  def num_zooms_per_training_pt
    num_zooms / (self.log.length - num_zooms - num_points_deleted).to_f
  end

  def num_zooms_per_training_pt_to_s
    "#{'%.3f' % num_zooms_per_training_pt}"
  end

  DefaultRadiusOfCorrectnessSqd = 5 ** 2 #5 pixels away
  def calculate_accuracy(r = DefaultRadiusOfCorrectnessSqd)
    self.precision, self.recall, tp, fp, fn = quality_and_accuracy_metrics.calculate_precision_recall_tp_fp_fn(r)
  end

  PrecisionThreshold = 0.2
  RecallThreshold = 0.2
  RADIUS_FOR_THRESHOLDING_SQD = 15 ** 2
  def not_accurate_enough?
    return true if !self.done? #if we're not done yet, it is inaccurate, so return true
    if self.accurate_enough.nil?
      max_precision, max_recall, tp, fp, fn = quality_and_accuracy_metrics.calculate_precision_recall_tp_fp_fn(RADIUS_FOR_THRESHOLDING_SQD)
      self.accurate_enough = max_precision > PrecisionThreshold && max_recall > RecallThreshold
      self.save!
    end
    !self.accurate_enough
  end

  def sum_of_sqd_distances
    @ssds ||= quality_and_accuracy_metrics.calculate_sum_of_sqd_distances
  end

  def sum_of_distances
    quality_and_accuracy_metrics.calculate_sum_of_distances
  end

  def avg_distance
    sds, points_to_distances = sum_of_distances
    sds / points_to_distances.length.to_f
  end

  def f_measure(beta = 1) #beta of 1 is standard f-measure
    return 0 if self.precision.zero? and self.recall.zero? #prevent the NaN errors
    (1 + (beta ** 2)) * self.precision * self.recall / ((beta ** 2) * self.precision + self.recall)
  end

  def accuracy_to_s
    "#{'%.1f' % (self.precision * 100)}%/#{'%.1f' % (self.recall * 100)}%/#{'%.1f' % (self.f_measure * 100)}%"
  end

  private
  def quality_and_accuracy_metrics
    @qaam ||= QualityAndAccuracyMetrics.new(self.image.truth_points, self.points_as_strings)
  end
end
