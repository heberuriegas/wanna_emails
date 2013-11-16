class SendEmailsWorker
  include Sidekiq::Worker

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)

    begin
      campaign.send_emails
    rescue Exception => e
      campaign.failure
    end
  end
end
