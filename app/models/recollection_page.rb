class RecollectionPage < ActiveRecord::Base
  belongs_to :recollection
  belongs_to :page

  has_many :emails_recollection_pages, class_name: 'EmailsRecollectionPages'
  has_many :emails, through: :emails_recollection_pages, dependent: :destroy

  has_many :phones, dependent: :destroy
  has_many :prospects, dependent: :destroy

  validates :emails_count, presence: true, numericality: true

  alias_attribute :emails_count, :emails_recollection_pages_count
end
