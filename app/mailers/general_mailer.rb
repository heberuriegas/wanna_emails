class GeneralMailer < ActionMailer::Base

  def general campaign_id, sender_id, email_id, message_id
    raise ('We need all data') unless campaign_id.present? and sender_id.present? and email_id.present? and message_id.present?
    campaign, sender, email, message = Campaign.find(campaign_id), Sender.find(sender_id), Email.find(email_id), Message.find(message_id)
    raise ('Email needs recollection_pages') unless email.recollection_pages.present?
    
    if sender.blocked?
      sender = Sender.availables(language: self.project.language).sample
      raise('All senders are blocked today') unless sender.present?
    end
    
    message = message.sanitize(sender,email.recollection_pages.sample, html: true)

    mail(
      from: "#{sender.name} <#{sender.email}>",
      to: email.address,
      content_type: "text/html",
      subject: message.subject,
      body: message.text,
      delivery_method_options: sender.configuration_hash)
  end
  
end
