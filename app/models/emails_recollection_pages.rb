class EmailsRecollectionPages < ActiveRecord::Base
  belongs_to :email
  belongs_to :recollection_page, counter_cache: true

  self.primary_key = [:email_id, :recollection_page_id]
end
