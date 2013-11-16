class SentEmail < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :email
  belongs_to :sender
  belongs_to :message

  before_create :set_date

  private
  def set_date
    self.sent_at = DateTime.now
  end
end