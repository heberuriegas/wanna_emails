# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require 'wanna_emails/contact_form'

namespace :seccion_amarilla do

  desc "Generate data dummy for services"
  task :recollect, [:section, :pages] => :environment do |t, args|
    args.with_defaults project: 'Asurela - Arquitectos'
    args.with_defaults recollection: 'Sección amarilla'
    args.with_defaults url: 'http://www.seccionamarilla.com.mx/'
    args.with_defaults category: 'arquitectos'
    args.with_defaults state: 'distrito-federal'
    args.with_defaults pages: '1-2'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    pages = args[:pages].split('-')

    include WannaEmails::ContactForm

    WannaEmails::ContactForm.agent = TorPrivoxy::Agent.new(host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true) do |agent|
      puts "New IP is: #{agent.ip}"
    end
    project = Project.where(name: args[:project]).first_or_create
    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create
    page_type = PageType.where(name: 'Contact Page').first_or_create

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3
        current_page_uri = "#{args[:url]}resultados/#{args[:category]}/#{args[:state].present? ? args[:state]+'/' : ''}#{n}"
        current_page current_page_uri
        logger.info "==== Visit Page: #{current_page_uri}/"

        prospect_page = Page.where(uri: current_page_uri).first_or_create
        recollection_page = RecollectionPage.where(recollection_id: recollection.id, page_id: prospect_page.id).first_or_create

        prospects = current_page.search('ul li.vcard')

        #businesses_urls = current_page.search('a.urchin').map{|link| Mechanize::Page::Link.new(link,agent,current_page)}
        prospects.each do |prospect_block|
          begin

            phone_numbers = []
            email_addresses = []

            prospect = Prospect.new

            prospect.name = prospect_block.search('h3').try(:first).try(:text).try(:strip)
            prospect.address = prospect_block.search('span.street-address').try(:first).try(:text).try(:strip)
            prospect.postal_code = prospect_block.search('span.postal-code').try(:first).try(:text).try(:strip)
            prospect.state = prospect_block.search('span.locality acronym').map{ |t| t.try(:text).try(:strip) }
            prospect.country = 'México'
            prospect.url = current_page.uri

            category_name = prospect_block.search('span.category').try(:first).try(:text).try(:strip)
            prospect.category = Category.where(name: category_name).first_or_create if category_name.present?

            phone_numbers << prospect_block.search('span.tel').try(:text).try(:gsub, /tel:|mobile:/i,'').try(:gsub, /llama gratis/i, '').try(:gsub, /\*|•/i, '').try(:strip)

            prospect_link = prospect_block.search('a.mas_info').first
            if prospect_link.present?
              if prospect_link['href'].present? && info_section = Mechanize::Page::Link.new(prospect_link,agent,current_page).click rescue nil && info_section.present?
                # Exist a section
                prospect.name = info_section.search('h1').try(:first).try(:text).try(:strip)
                email_addresses << info_section.search('a.correo').try(:first).try(:[], 'href').try(:gsub, 'mailto:','').try(:strip)

                prospect.address = info_section.search('span.street-address').try(:first).try(:text).try(:strip)
                prospect.postal_code = info_section.search('span.postal-code').try(:first).try(:text).try(:strip)
                prospect.state = info_section.search('span.locality acronym').map{ |t| t.try(:text).try(:strip) }

                prospect.products = info_section.search('.servicios li').map do |t|
                  Product.where(name: t.try(:text).try(:strip)).first_or_create
                end

                prospect.hours = info_section.search('.horarios').try(:first).try(:text).try(:strip)
                prospect.url = info_section.uri

                phone_numbers.concat(info_section.search('li.tel').map{|t| t.try(:text).try(:gsub, /tel:|mobile:/i,'').try(:gsub, /llama gratis/i, '').try(:gsub, /\*|•/i, '').try(:strip) })
              end
            end

            phones = phone_numbers.uniq.map do |phone_number|
              Phone.where(number: phone_number)
            end

            emails = email_addresses.map do |email_address|
              Email.where(address: email_address).first_or_create]
            end

            if prospect.save
              prospect.phones = phones
              prospect.emails = emails

              recollection_page.phones = phones
              recollection_page.emails = phones
            end

=begin
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
=end
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

    while true do
      pages = Page.joins(:recollections).where(page_type_id: page_type.id, posted: false, recollections: {project_id: project.id})

      pages.each do |page|
        begin
          current_page page.uri
          logger.info "== Visit: #{current_page.uri.to_s}"

          fill_form project, contact_form, page
          sleep 3
          Page.find(page.id).update_attribute :posted, true
          logger.info "==== Posted: #{current_page.uri.to_s}"
        rescue StandardError => e
          logger.error "== Error: #{e.message}" unless e.message.include?('Connection refused') or e.message.include?('getaddrinfo') or e.message.include?('ContactForm')
        ensure
          begin
            error = false
            session.reset_session!
          rescue Selenium::WebDriver::Error::UnhandledAlertError => e
            error = true
          end while error
        end
      end
    end
  end
end