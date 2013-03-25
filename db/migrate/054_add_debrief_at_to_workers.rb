class AddDebriefAtToWorkers < ActiveRecord::Migration
  def change
    add_column :workers, :debriefed_at, :datetime
  end
end
