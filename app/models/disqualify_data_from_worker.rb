class DisqualifyDataFromWorker < ActiveRecord::Base
  validates_presence_of :mturk_worker_id
  validates_presence_of :reason
  validates_presence_of :user
  validates_presence_of :level
  validates_presence_of :error_code

  belongs_to :user

  ALL_DATA_LEVEL = 1
  QUANTITATIVE_DATA_LEVEL = 2

  Explanations = {
    ALL_DATA_LEVEL => '1: Disqualify data for both qualitative and quantitative results',
    QUANTITATIVE_DATA_LEVEL => '2: Disqualify data for ONLY quantitative results'
  }
  def worker
    @w ||= Worker.find_by_mturk_worker_id(self.mturk_worker_id)
  end
end
