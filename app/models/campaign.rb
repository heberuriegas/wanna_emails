class Campaign < ActiveRecord::Base
  belongs_to :project
  belongs_to :user

  has_and_belongs_to_many :recollections

  validates :name, presence: true

  STATES = {
    waiting: 0,
    started: 1,
    in_progress: 2,
    finished: 3,
    failed: 4
  }

  state_machine initial: :waiting do
    STATES.each do |name, value|
      state name, value: value
    end

    after_transition any => :started do |campaign|
      campaign.clean_log
      campaign.record_starts_at

      SendEmailsWorker.perform_async campaign.id
      #campaign.send_emails
    end

    after_transition any => :finished do |campaign|
      campaign.log_success
    end

    after_failure do |campaign,transition|
      campaign.log_failure campaign, transition
      campaign.record_ends_at
    end

    event :start do
      transition waiting: :started
    end

    event :start_progress do
      transition all => :in_progress
    end

    event :finish do
      transition in_progress: :finished
    end

    event :try_again do
      transition all => :started
    end

    event :failure do
      transition all => :failed
    end
  end

  def status
    STATES.key(self.state).capitalize
  end

  def state_name
    STATES.key(self.state)
  end

  def log_failure campaign, transition
    report = "Campaign #{campaign.name} failed on #{transition.event}"
    Rails.logger.error report
    campaign.update_attribute :report, report
    campaign.failure
  end

  def emails
    emails = []
    self.recollections.each do |recollection|
      emails.concat recollection.emails
    end
    emails.uniq{|email| email.address}
  end

  def emails_available
    emails = []
    self.recollections.each do |recollection|
      emails.concat recollection.emails_available
    end
    emails.uniq{|email| email.address}
  end

  def record_ends_at
    self.update_attribute :ends_at, Time.now
  end

  def record_starts_at
    self.update_attributes starts_at: Time.now, ends_at: nil
  end

  def clean_log
    self.update_attribute :report, nil
  end

  def log_success
    self.record_ends_at
    report = 'Campaign finish succesfully'
    self.update_attribute :report, report
    Rails.logger.info report
  end

  def self.send_email campaign_id, sender_id, email_id, message_id
    begin
      GeneralMailer.general(campaign_id, sender_id, email_id, message_id).deliver!

      campaign, sender, email, message = Campaign.find(campaign_id), Sender.find(sender_id), Email.find(email_id), Message.find(message_id)
      SentEmail.create(campaign: campaign, sender: sender, message: message, email: email)

      GeneralMailer.logger.info "== Sent email from: #{sender.email} to #{email.address}"
    rescue Net::SMTPAuthenticationError => e
      sender = Sender.find(sender_id)
      sender.block!
      GeneralMailer.logger.error "==== Sender #{sender.email} was blocked!"
      GeneralMailer.logger.error e.message
    rescue Exception => e
      GeneralMailer.logger.error "==== Error in Email id: #{email_id}"
      GeneralMailer.logger.error e.message
      GeneralMailer.logger.error e.backtrace.join("\n")
    end
  end

  def send_emails
    transaction { self.start_progress }
    begin
      senders = Sender.availables(language: self.project.language)
      messages = self.project.messages
      minutes = Time.diff(DateTime.now,DateTime.tomorrow)[:hour]*60+Time.diff(DateTime.now,DateTime.tomorrow)[:minute]

      self.emails_available[0...Sender.availables_count(language: self.project.language)].each do |email|
      #self.emails[0...5].each do |email|
        Campaign.delay_for(rand(minutes).minutes).send_email(self.id, senders.sample.id, email.id, messages.sample.id)
        #GeneralMailer.general(self.id, senders.sample.id, email.id, messages.sample.id).deliver!
      end

    rescue Exception => e
      self.failure
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
    transaction { self.finish }
  end
end
