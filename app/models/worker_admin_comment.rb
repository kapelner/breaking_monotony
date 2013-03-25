class WorkerAdminComment < ActiveRecord::Base
  belongs_to :worker
  belongs_to :user
  
  
end
