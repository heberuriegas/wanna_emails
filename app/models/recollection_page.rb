class RecollectionPage < ActiveRecord::Base
  belongs_to :recollection
  belongs_to :page

  validates :number_of_emails, presence: true, numericality: { greater_than: 0 }
end
