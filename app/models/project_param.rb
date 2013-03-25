class ProjectParam < ActiveRecord::Base
  def ProjectParam.getvals
    @pp ||= ProjectParam.find(:first)
  end
end
