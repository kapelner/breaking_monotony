class MHit < ActiveRecord::Base
  include EncryptionTools
  
  #experimental constants
  AllTreatments = %w(meaningful zero_context shredded)
  USA = 1
  INDIA = 2
  WAGES = %w(0.10 0.09 0.08 0.07 0.06 0.05 0.04 0.03 0.02)


  extend BmomMTurk

  has_many :workers #don't destroy these, we need to keep a list of people who saw these HITs
  has_many :m_hit_views, :dependent => :destroy

  serialize :wage_schedule


  validates_inclusion_of :experimental_country, :in => [USA, INDIA]
  validates :version_number, :presence => true
  validates :wage_schedule, :presence => true


  def current_worker
    @cw ||= Worker.find_by_mturk_worker_id(self.current_mturk_worker_id)
  end

  def experimental_country_to_text
    case self.experimental_country
      when USA
        "US"
      when INDIA
        "IN"
      else
        raise "no experimental country in hit #{self.id}"
    end
  end

  def MHit.randomize_experimental_group
    AllTreatments.sort_by{rand}.first
  end

  NumDefaultHITsToCreatePerInterval = Rails.env.development? ? 5 : 50
  def MHit.create_hit_set_for_both_india_and_us
    NumDefaultHITsToCreatePerInterval.times do
      MHit.create_new_hit_on_mturk(MHit::USA)
      MHit.create_new_hit_on_mturk(MHit::INDIA)
    end
    "success"
  end

  def MHit.create_new_hit_on_mturk(country)
    hit = MHit.create({
      :experimental_country => country,
      :wage_schedule => WAGES,
      :version_number => ProjectParam.getvals.current_version_number,
      :expire_at => Time.now + BmomMTurk::DEFAULT_HIT_LIFETIME
    })
    mturk_hit = create_bmom_hit_on_mturk(hit)
    hit.mturk_hit_id = mturk_hit.hit_id
    hit.mturk_group_id = mturk_hit.type_id
    hit.save!
  end

  def admin_view?
    self.version_number >= ProjectParam.getvals.current_version_number
  end

  def initial_wage
    self.wage_schedule.first
  end

  #if we get wage longer than array, just return last entry
  def get_wage_for_image_number(n)
    (n > self.wage_schedule.length - 1) ? self.wage_schedule.last : self.wage_schedule[n]
  end

  def expired?
    Time.now > self.expire_at
  end

  def row_color
    if accepted?
      'green'
    elsif rejected?
      'red'
    elsif expired?
      'gray'
    else
      'black'
    end
  end

  def accepted?
    current_worker ? (current_worker.payment_outcome ? current_worker.payment_outcome.accepted? : false) : false
  end

  def rejected?
    current_worker ? (current_worker.payment_outcome ? current_worker.payment_outcome.rejected? : false) : false
  end

  def MHit.t_str(t, h, strftime = '%m/%d %H:%M')
    return nil if t.nil?
    country = if h.class == MHit
                h.experimental_country
              elsif h.class == Fixnum
                h
              end
    if country == INDIA
      t.ago((13.5).hours).strftime(strftime) + " IST"
    elsif country == USA
      t.ago(0.hours).strftime(strftime) + " EST"
    end
  end
end

=begin
cd /data/<anonymized>/current && bundle exec rails runner -e production 'MHit.create_hit_set_for_both_india_and_us'
=end
