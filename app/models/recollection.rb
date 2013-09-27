class Recollection < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_and_belongs_to_many :emails
  has_many :recollection_pages
  has_many :pages, through: :recollection_pages

  validates :name, presence: true
  validates :date, presence: true
  validates :latitude, numericality: true
  validates :longitude, numericality: true
  validates :goal, presence: true, numericality: { greater_than: 0, less_than: 100000 }

  validates_presence_of :user

  acts_as_gmappable check_process: false

  @@email_providers = [:gmail, :outlook, :hotmail, :live, :yahoo]
  @@sufix_domains = [:com]

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

    after_transition any => :started do |recollection|
      recollection.clean_log
      recollection.record_starts_at

      EmailWorker.perform_async recollection.id
      #recollection.get_emails
    end

    after_transition any => :finished do |recollection|
      recollection.log_success
    end

    after_failure do |recollection,transition|
      recollection.log_failure recollection, transition
      recollection.record_ends_at
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

  def gmaps4rails_address
    "#{self.name} - #{self.address}"
  end

  def status
    STATES.key(self.state).capitalize
  end

  def state_name
    STATES.key(self.state)
  end

  def reach
    "#{self.emails.count} emails - #{((self.emails.count.to_f/self.goal.to_f)*100).round(2)}% of the total" if self.emails.present?
  end

  def log_failure recollection, transition
    report = "Recollection #{recollection.name} failed on #{transition.event}"
    Rails.logger.error report
    recollection.update_attribute :report, report
    recollection.failure
  end

  def email_providers options = {}
    options.reverse_merge! another_providers: [], another_domains: []

    result = []
    (@@sufix_domains + options[:another_domains]).each do |domain|
      (@@email_providers + options[:another_providers]).each do |provider|
        result << "\"@#{provider}.#{domain}\""
      end
    end

    "#{result.join(' OR ')}"
  end

  def search_query
    address = self.address.split(',').reverse
    address = address.count >= 2 ? address[2] : address[address.count]
    "(#{self.search}) AND (#{email_providers}) AND (\"#{address}\")"
  end

  def save_emails recollections
    emails = recollections.map{ |recollection| recollection[:email] }

    emails.each_slice(1000).to_a.each do |emails|
      emails_created = Email.create(emails.map{ |address| { address: address } })
      self.emails << emails_created.select{ |email| email.persisted? }
    end
  end

  def save_pages recollections
    recollections.group_by { |recollection| recollection[:uri] }.each do |uri,recollection|
      page = Page.where(host: recollection[0][:host], uri: uri).first_or_create
      page_recollection = RecollectionPage.where(recollection: self, page: page).first_or_create
      page_recollection.update_attribute :number_of_emails, recollection.count
    end
  end

  def get_emails
    transaction { self.start_progress }
    begin
      email_recollector = EmailRecollector.new
      recollections = email_recollector.search(self.search_query, self.goal)

      unless recollections.nil? || recollections.empty?
        save_emails recollections
        save_pages recollections
      end
    rescue Exception => e
      self.failure
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
    transaction { self.finish }
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
    report = 'Recollection finish succesfully'
    self.update_attribute :report, report
    Rails.logger.info report
  end
end
