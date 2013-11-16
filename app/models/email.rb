class Email < ActiveRecord::Base
  has_many :emails_recollection_pages, class_name: 'EmailsRecollectionPages'
  has_many :recollection_pages, through: :emails_recollection_pages

  validates :address, presence: true, uniqueness: true
  validates :address, :email_format => {:message => 'is not looking good'}
end
