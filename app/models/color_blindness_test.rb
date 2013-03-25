class ColorBlindnessTest < ActiveRecord::Base

  validates_presence_of :worker_id
  validates_presence_of :number_in_box
  validates_inclusion_of :male_female, :in => 0..1
  validates_inclusion_of :trouble_red_green, :in => [true, false]
  validates_inclusion_of :trouble_blue_yellow, :in => [true, false]
  validates_presence_of :age
  validates_format_of :word, :with => /^rock$/i

  def colorblind?
    (![20, 28, 29, 19, 39].include?(self.number_in_box)) or self.trouble_red_green? or self.trouble_blue_yellow?
  end

  MIN_AGE = 18
  MAX_AGE = 65
  def too_young_or_too_old?
    self.age < MIN_AGE || self.age > MAX_AGE
  end

  def male_female_string
    case self.male_female
      when 1
        'M'
      when 0
        'F'
      else
        raise "Invalid M/F code"
    end
  end
end
