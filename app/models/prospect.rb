class Prospect < ActiveRecord::Base
  belongs_to :category
  belongs_to :recollection_page
  has_many :phones
  has_and_belongs_to_many :products
end
