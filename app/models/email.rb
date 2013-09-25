class Email < ActiveRecord::Base
  has_and_belongs_to_many :recollections

  validates :address, presence: true, uniqueness: true
  validates :address, :email_format => {:message => 'is not looking good'}
end
