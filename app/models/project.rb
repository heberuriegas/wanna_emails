class Project < ActiveRecord::Base
  has_many :recollections, dependent: :destroy
  has_many :campaigns
  has_many :messages

  validates :name, presence: true

  def clean
    _campaigns = self.campaigns.all
    _recollections = []
    _recollection_pages = []
    _pages = []
    _prospects = []

    _recollections << self.recollections

    _campaigns.each do |campaign|
      _recollections << campaign.recollections
    end

    _recollections.each do |recollection|
      recollection.each do |_recollection|
        _recollection.recollection_pages.each do |recollection_page|
          _recollection_pages << recollection_page
        end
      end
    end

    _recollection_pages.each do |recollection_page|
      _pages << recollection_page.page
      _prospects << recollection_page.prospects
    end

    _pages.uniq.each { |t| t.destroy }
    _prospects.uniq.each { |t| t.destroy }
    _recollection_pages.uniq.each { |t| t.destroy }
    _recollections.uniq.each { |t| t.destroy }
  end
end
