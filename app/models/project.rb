class Project < ActiveRecord::Base
  has_many :recollections, dependent: :destroy
  has_many :campaigns
  has_many :messages

  validates :name, presence: true
end
