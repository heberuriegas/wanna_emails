class Page < ActiveRecord::Base
  has_many :recollection_pages
  has_many :recollections, through: :recollection_pages

  validates :host, presence: true
  validates :uri, presence: true
end