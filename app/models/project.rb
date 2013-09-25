class Project < ActiveRecord::Base
  has_many :recollections
  has_many :campaigns

  validates :name, presence: true
end
