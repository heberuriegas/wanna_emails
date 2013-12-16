# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require 'wanna_emails/contact_form'

namespace :amarillas do

  desc "Generate data dummy for services"
  task :recollect, [:section, :pages] => :environment do |t, args|
    args.with_defaults project: 'TradeGig Santiago Contact'
    args.with_defaults recollection: 'Amarillas'
    args.with_defaults url: 'http://www.amarillas.cl/'
    args.with_defaults section: 'b/a-domicilio/'
    args.with_defaults pages: '1-2'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    pages = args[:pages].split('-')

    include WannaEmails::ContactForm

    WannaEmails::ContactForm.agent = TorPrivoxy::Agent.new(host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true) do |agent|
      #puts "New IP is: #{agent.ip}"
    end
    
    project = Project.where(name: args[:project]).first_or_create

    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create

    page_type = PageType.where(name: 'Contact Page').first_or_create

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3
        current_page_uri = "#{args[:url]}#{args[:section]}/page=#{n}/"
        current_page current_page_uri
        logger.info "==== Visit Page: #{current_page_uri}/"
        businesses_urls = current_page.search('h3.m-results-business--name a.urchin').map{|link| Mechanize::Page::Link.new(link,agent,current_page)}
        businesses_urls.each do |business_url|
          begin
            
            business_page = Page.where(uri: "#{args[:url]}#{business_url.href}").first_or_create

            unless business_page.posted == true
              current_page business_url.href
              logger.info "== Visit: #{current_page.uri.to_s}"

              recollection_page = RecollectionPage.where(recollection_id: recollection.id, page_id: business_page.id).first_or_create
              
              #Save Emails
              email_addresses = current_page.search('div#webmail li.omega a').map{|t| t.text}
              emails = email_addresses.map{ |email_address| Email.where(address: email_address).first_or_create }
              emails.each { |email| EmailsRecollectionPages.where(recollection_page_id: recollection_page.id, email_id: email.id).first_or_create }
              logger.info "Emails: #{email_addresses.join(', ')} recollected" if email_addresses.present?

              #Save WebPages
              webpage_uris = current_page.search('div#webmail li a').map{|t| t.text} - email_addresses
              webpages = webpage_uris.map{ |webpage_uri| Page.where(uri: "http://#{webpage_uri}", page_type_id: page_type.id).first_or_create }
              webpages.each{ |webpage| RecollectionPage.where(recollection_id: recollection.id, page_id: webpage.id).first_or_create }
              logger.info "Webpages: #{webpage_uris.join(', ')} recollected" if webpage_uris.present?

              #Save Phone numbers
              phone_number = current_page.search('span[itemprop="telephone"]').text.gsub("\t",'').gsub("\n",'')
              recollection_page.phones << Phone.where(number: phone_number).first_or_create unless recollection_page.phones.pluck(:number).include?(phone_number) or !phone_number.present?
              logger.info "Phone: #{phone_number} recollected" if phone_number.present?
            
              business_page.update_attribute :posted, true
          
              sleep 3
            end
          rescue Exception => e
            logger.error "== Error: #{e.message}"
            agent.switch_circuit if args[:tor] == 'true'
          end    
        end
      rescue Exception => e
        logger.error "== Error: #{e.message}"
        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end

  desc "Generate data dummy for services"
  task :post_messages, [:project] => :environment do |t, args|
    args.with_defaults project: 'TradeGig Santiago Contact'

    logger = Logger.new("log/posts/amarillas_posts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    include WannaEmails::ContactForm

    project = Project.where(name: args[:project]).first_or_create
    page_type = PageType.where(name: 'Contact Page').first_or_create

    pages = Page.joins(:recollections).where(page_type_id: page_type.id, posted: false, recollections: {project_id: project.id})

    pages[0..25].each do |page|
      begin
        current_page page.uri
        logger.info "== Visit: #{current_page.uri.to_s}"

        fill_form project
        sleep 3
      rescue Exception => e
        logger.error "== Error: #{e.message}"
      end
    end
  end
end