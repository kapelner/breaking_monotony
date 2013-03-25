class PaymentOutcome < ActiveRecord::Base
  belongs_to :worker

  validates_presence_of :worker_id
  validates_inclusion_of :rejected, :in => [true, false]
  validates_inclusion_of :accepted, :in => [true, false]
  validates_inclusion_of :never_submitted_therefore_never_paid, :in => [true, false]
  validates_presence_of :total_payout

  def to_str
    if self.rejected?
      'Rejected'
    elsif self.accepted?
      "Accepted and paid $#{self.total_payout}"
    elsif self.never_submitted_therefore_never_paid?
      "Never submitted thereby never paid"
    end
  end
end
