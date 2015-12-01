class Page < ActiveRecord::Base
  has_many :recollection_pages
  has_many :recollections, through: :recollection_pages
  belongs_to :page_type

  validates :host, presence: true
  validates :uri, presence: true

  def uri=(uri)
    temp_uri = uri.is_a?(URI) ? uri : URI.parse(uri) 
    self[:host] = temp_uri.host
    self[:uri] = temp_uri.to_s
  end
end