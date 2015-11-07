class Phone < ActiveRecord::Base
  belongs_to :recollection_page
  belongs_to :prospect
end
