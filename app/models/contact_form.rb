class ContactForm
  include ActiveModel::Model

  attr_accessor :emails, :recollections

  def initialize contact_form, agent = Mechanize.new
    @contact_form = contact_form
    @agent = agent
  end

  


end