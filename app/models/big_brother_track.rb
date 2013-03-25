class BigBrotherTrack < ActiveRecord::Base
  belongs_to :user
  has_many :big_brother_params#, :dependent => :destroy
  
  attr_accessor :delta_t
  attr_accessor :total_time_for_session
  
  def <=>(other)
    case
      when self.id > other.id then 1
      when self.id < other.id then -1
    end
  end
end
