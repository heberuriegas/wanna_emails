class EmailsRecollectionPages < ActiveRecord::Base
  belongs_to :email
  belongs_to :recollection_page

  self.primary_key = [:email_id, :recollection_page_id]

  after_save :update_counter_cache
  after_destroy :update_counter_cache

  def update_counter_cache
    self.recollection_page.update_attribute :emails_recollection_pages_count, self.recollection_page.emails.uniq{|email| email.address}.count
  end
end
  