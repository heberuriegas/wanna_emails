class Recollection < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  
  has_many :recollection_pages
  has_many :pages, through: :recollection_pages, dependent: :destroy

  validates :name, presence: true
  validates :date, presence: true, if: "user.present?"
  validates :latitude, numericality: true, if: "user.present?"
  validates :longitude, numericality: true, if: "user.present?"
  validates :goal, presence: true, numericality: { greater_than: 0, less_than: 100000 }, if: "user.present?"

  after_validation :reverse_geocode

  reverse_geocoded_by :latitude, :longitude do |recollection,results|
    if geo = results.first
      recollection.country_code = geo.country_code
    end
  end

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
    if self.recollection_pages.present?
      #emails = self.recollection_pages.sum('emails_recollection_pages_count')
      emails = self.emails.count
      self.goal.present? ? "#{emails} emails - #{((emails.to_f/self.goal.to_f)*100).round(2)}% of the total" : "#{emails} Emails"
    end
  end

  def log_failure recollection, transition
    report = "Recollection #{recollection.name} failed on #{transition.event}"
    Rails.logger.error report
    recollection.update_attribute :report, report
    recollection.failure
  end

  def emails
    #Email.includes(:recollection_pages).where('recollection_pages.recollection_id = ?',self.id).references(:recollection_pages)
    Email
      .joins(:recollection_pages)
      .where('recollection_pages.recollection_id = ?',self.id)
      .uniq{|email| email.address}
  end

  def emails_available days = 30
    Email
      .joins(:recollection_pages)
      .where('recollection_pages.recollection_id = ?',self.id)
      .where("TIMESTAMP '#{DateTime.now.strftime('%Y-%m-%d')}' - last_sent_at >= INTERVAL '#{days} days' OR last_sent_at is NULL")
      .uniq{|email| email.address}
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
    result = "(#{self.search}) AND (#{email_providers})"

    if self.search_by_city == true
      address = self.address.split(',').reverse
      address = address.count >= 2 ? address[2] : address[address.count]
      result.concat " AND (\"#{address}\")"
    end
    result
  end

  def save_emails_and_pages recollections
    recollections.group_by { |recollection| recollection[:uri] }.each do |uri,recollections|

      page = Page.where(host: recollections[0][:host], uri: uri).first_or_create

      recollection_page = RecollectionPage.where(recollection: self, page: page).first_or_create

      recollections.each_slice(500) do |recollections|
        transaction do
          recollections.each do |recollection|
            email = Email.where(address: recollection[:email]).first_or_create
            EmailsRecollectionPages.where(recollection_page: recollection_page, email: email).first_or_create
          end
        end
      end
    end
  end

  def get_emails
    transaction { self.start_progress }
    begin
      email_recollector = EmailRecollector.new
      recollections = email_recollector.search(self.search_query, self.country_code, self.goal)

      save_emails_and_pages recollections unless recollections.nil? || recollections.empty?
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
