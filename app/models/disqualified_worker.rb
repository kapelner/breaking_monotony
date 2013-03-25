class DisqualifiedWorker < ActiveRecord::Base
  validates_presence_of :mturk_worker_id
end
