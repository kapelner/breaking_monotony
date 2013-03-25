class Qualification < ActiveRecord::Base
  belongs_to :worker

  validates_presence_of :worker_id
end
