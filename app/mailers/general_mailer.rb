class GeneralMailer < ActionMailer::Base

  def general campaign_id, sender_id, email_id, message_id
    begin
      campaign, sender, email, message = Campaign.find(campaign_id), Sender.find(sender_id), Email.find(email_id), Message.find(message_id)
      throw ('Email needs recollection_pages') unless email.recollection_pages.present?
      
      if sender.blocked?
        sender = Sender.availables(language: self.project.language).sample
        throw('All senders are blocked today') unless sender.present?
      end
      
      message = message.sanitize(sender,email.recollection_pages.sample, html: true)

      mail(
        from: "#{sender.name} <#{sender.email}>",
        to: email.address,
        content_type: "text/html",
        subject: message.subject,
        body: message.text,
        delivery_method_options: sender.sender_entity.configuration_hash(sender))

      email.update_attribute :last_sent_at, DateTime.now.strftime('%Y-%m-%d')
      SentEmail.create(campaign: campaign, sender: sender, message: message, email: email)
      logger.info "== Sent email from: #{sender.email} to #{email.address}"
    rescue Exception => e
      logger.error "==== Error in Email id: #{email_id}"
      logger.error e.message
      logger.error e.backtrace.join("\n")
    end
  end

end
