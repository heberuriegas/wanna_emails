class EmailRecollector
  include ActiveModel::Model

  attr_accessor :emails
  
  @@profiles = {
    google: {
      base_uri: 'http://google.com.mx/',
      reg_uri: /^\/url\?q=(.*)/,
      limit_page: 100,
      extract_links: lambda { |link| link.href[7..-1].split('&')[0] }
    }
  }

  @@reg_email = /[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}/i
 
  def initialize profile = :google, persistent = true
    @agent = Mechanize.new
    @profile = @@profiles[:google]
    @recollections = []
    @persistent = persistent
  end
  
  def search q, goal=10000, lag=5, salt=false
    begin
      search = get_page(@profile[:base_uri])
      result = submit_form search, q

      recollect_emails_from result
      log_page 1
      sleep lag

      (2..@profile[:limit_page]).each do |i|
        result = click_number(result,i)
        break if @recollections.count >= goal or result.nil?
        recollect_emails_from result
        log_page i
        sleep lag
      end

      @recollections.sort_by!{ |recollection| recollection[:email] } unless @recollections.nil?
      @recollections
    rescue Exception => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end 
  end

  private

  # Get a page
  def get_page page
    begin
      @agent.get page
    rescue Exception => e
      #Rails.logger.error e.message
    end
  end

  # Submit search form
  def submit_form page, q
    begin
      form = page.forms.first
      form['q'] = q
      @agent.submit form
    rescue Exception => e
      Rails.logger.error e.message
    end
  end
  
  # Scan page and get links
  def recollect_emails_from page
    begin
      recollect_emails page
      links = get_links(page)
      links.each do |link|
        recollect_emails get_page(link)
      end unless links.nil?
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

  # Recollect emails
  def recollect_emails page
    begin
      if page.present? and page.respond_to? :title and page.respond_to? :body
        emails = []
        emails.concat get_emails(page.title)
        emails.concat get_emails(page.body)

        recollections = emails.map do |email|
          { email: email, host: page.uri.host, uri: page.uri.to_s }
        end

        @recollections.concat recollections
      end
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

  # Click in a number of link
  def click_number page, i
    begin
      number = page.links_with(text: (i).to_s).first
      number.click unless number.nil?
    rescue Exception => e
      Rails.logger.error e.message
    end
  end

  # Get all links of a profile
  def get_links page
    begin
      page.links.select{|link| link.href =~ @profile[:reg_uri]}.map{|link| @profile[:extract_links].call(link) } unless page.nil?
    rescue Exception => e
      Rails.logger.error e.message
      return []
    end
  end
  
  # Get all emails of a text
  def get_emails text
    begin
      result = text.scan(@@reg_email).uniq unless text.nil?
      return result.nil? ? [] : result
    rescue Exception => e
      Rails.logger.error e.message
      return []
    end
  end

  # Just for log
  def log_page i
    Rails.logger.info "Page #{i} collected, you have #{@recollections.size} emails ..."
  end

end

=begin
c = CollectEmail.new(:google, false)
c.search('"soy mama" monterrey @gmail.com')
c.emails.count
=end