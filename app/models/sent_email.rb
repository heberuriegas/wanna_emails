class SentEmail < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :email
  belongs_to :sender
  belongs_to :message

  before_create :set_date
  after_create :set_email_last_sent_at

  private
  def set_date
    self.sent_at = DateTime.now
  end

  def set_email_last_sent_at
    self.email.update_attribute :last_sent_at, DateTime.now.strftime('%Y-%m-%d')
  end
end