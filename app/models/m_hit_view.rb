class MHitView < ActiveRecord::Base
  belongs_to :m_hit

  validates_presence_of :m_hit_id
  validates_presence_of :ip_address
end
