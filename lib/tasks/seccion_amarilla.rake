# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require 'wanna_emails/contact_form'

namespace :seccion_amarilla do

  desc "Generate data dummy for services"
  task :recollect, [:category, :state, :pages] => :environment do |t, args|
    args.with_defaults project: 'Asurela - Comercio'
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

    (pages[0].to_i...pages[1].to_i+1).each_with_index do |n,index|
      begin
        logger.info "==== Start Page: #{n}"
        agent.switch_circuit if index % 3 == 3
        current_page_uri = "#{args[:url]}resultados/#{args[:category]}/#{args[:state].present? ? args[:state]+'/' : ''}#{n}"

        current_page current_page_uri rescue next
        logger.info "== Visit Page: #{current_page_uri}"

        list_page_type = PageType.where(name: 'List Page').first_or_create
        contact_page_type = PageType.where(name: 'Contact Page').first_or_create

        prospect_page = Page.where(uri: current_page_uri, page_type: list_page_type).first_or_create

        if prospect_page.fetched?
          logger.info "== Skip Fetched Page: #{prospect_page.uri}"
          next
        end

        recollection_page = RecollectionPage.where(recollection_id: recollection.id, page_id: prospect_page.id).first_or_create

        prospects = current_page.search('ul li.vcard')

        logger.info "== #{n} prospects finded"

        #businesses_urls = current_page.search('a.urchin').map{|link| Mechanize::Page::Link.new(link,agent,current_page)}
        prospects.each do |prospect_block|
          begin
            phone_numbers = []
            email_addresses = []
            product_names = []

            prospect = Prospect.new

            prospect_name = prospect_block.search('h3').try(:first).try(:text).try(:strip)

            logger.info "==== Start scrap prospect: #{prospect_name}"

            prospect.recollection_page = recollection_page

            prospect.name = prospect_name
            prospect.address = prospect_block.search('span.street-address').try(:first).try(:text).try(:strip)
            prospect.postal_code = prospect_block.search('span.postal-code').try(:first).try(:text).try(:gsub, ',', '').try(:strip)
            prospect.state = prospect_block.search('span.locality acronym').try(:first).try(:text).try(:strip)
            prospect.country = 'México'
            prospect.url = current_page.uri.to_s

            category_name = args[:category].capitalize
            prospect.category = Category.where(name: category_name).first_or_create if category_name.present?

            subcategory_name = prospect_block.search('span.category').try(:first).try(:text).try(:strip)
            prospect.subcategory = Category.where(name: subcategory_name).first_or_create if subcategory_name.present?

            phone_numbers << prospect_block.search('span.tel').try(:text).try(:gsub, /tel:|mobile:/i,'').try(:gsub, /llama gratis/i, '').try(:gsub, /\*|•/i, '').try(:strip)

            prospect_link = prospect_block.search('a.mas_info').first

            if prospect_link.present? && prospect_link['href'].present? && info_section = Mechanize::Page::Link.new(prospect_link,agent,current_page).click rescue nil && info_section.present?
              contact_page = Page.where(uri: info_section.uri.to_s, page_type: contact_page_type).first_or_create
              recollection_contact_page = RecollectionPage.where(recollection_id: recollection.id, page_id: contact_page.id).first_or_create
              prospect.recollection_page = recollection_contact_page

              # Exist a section
              logger.info "==== Start scrap prospect detail: #{prospect_name}"
              prospect.name = info_section.search('h1').try(:first).try(:text).try(:strip)
              prospect.address = info_section.search('span.street-address').try(:first).try(:text).try(:strip)
              prospect.postal_code = info_section.search('span.postal-code').try(:first).try(:text).try(:gsub, ',', '').try(:strip)
              prospect.state = info_section.search('span.locality acronym').try(:first).try(:text).try(:strip)
              prospect.hours = info_section.search('.horarios').try(:first).try(:text).try(:strip)
              prospect.url = info_section.uri.to_s

              email_addresses << info_section.search('a.correo').try(:first).try(:[], 'href').try(:gsub, 'mailto:','').try(:strip)
              phone_numbers.concat(info_section.search('li.tel').map{|t| t.try(:text).try(:gsub, /tel:|mobile:|tel\/fax:/i,'').try(:gsub, /llama gratis/i, '').try(:gsub, /\*|•/i, '').try(:strip) }.select{|t| t.present?}.uniq)
              product_names.concat(info_section.search('.servicios li').map{ |t| t.try(:text).try(:strip) }.select{|t| t.present?}.select{|t| t.present?}.uniq)
            end

            products = product_names.map do |product_name|
              Product.where(name: product_name).first_or_create
            end

            phones = phone_numbers.map do |phone_number|
              Phone.where(number: phone_number).first_or_create
            end

            emails = email_addresses.map do |email_address|
              Email.where(address: email_address).first_or_create
            end

            old_prospect = Prospect.where(name: prospect.name, address: prospect.address, postal_code: prospect.postal_code, state: prospect.state, country: prospect.country).try(:first)

            if (old_prospect.present? && prospect = old_prospect) || prospect.save
              logger.info "==== Prospect saved successfully: #{prospect_name}"

              products.each do |product|
                prospect.products << product rescue nil                
              end

              phones.each do |phone|
                prospect.phones << phone rescue nil
                prospect.recollection_page.phones << phone rescue nil
              end

              emails.each do |email|
                prospect.emails << email rescue nil
                prospect.recollection_page.emails << email rescue nil
              end
            end
          rescue Exception => e
            logger.error "== Error: #{e.message}"
            logger.error e.backtrace.join("\n")
            agent.switch_circuit if args[:tor] == 'true'
          end    
        end
        prospect_page.update_attribute :fetched, true
        sleep 3
      rescue Exception => e
        logger.error "== Error: #{e.message}"
        logger.error e.backtrace.join("\n")
        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end

  desc "Generate data dummy for services"
  task :post_messages, [:project] => :environment do |t, args|
    args.with_defaults project: 'Asurela - Comercio'
    args.with_defaults recollection: 'Sección amarilla'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    page_type = PageType.where(name: 'Contact Page').first_or_create

    include WannaEmails::ContactForm
    @@dictionary =  YAML::load_file 'config/locales/dictionary_seccion_amarilla.yml'
    @@dynamic_fill = false

    project = Project.where(name: args[:project]).first_or_create

    while true do
      pages = Page.joins(:recollections).where(posted: false, recollections: {project_id: project.id}, page_type: page_type)

      logger.info "While! pages: #{pages.size}"
      pages.each do |page|
        begin
          current_page page.uri
          logger.info "== Visit: #{current_page.uri.to_s}"

          super_page_link = current_page.search('a.super_pagina').first
          if super_page_link.present? && super_page_link['href'].present? && super_page_section = Mechanize::Page::Link.new(super_page_link,agent,current_page).click rescue nil && super_page_section.present?
            fill_form project, page, contact_form(super_page_section)
            sleep 3
            Page.find(page.id).update_attribute :posted, true
            logger.info "==== Super page found, Posted: #{current_page.uri.to_s}"
          else
            Page.find(page.id).update_attribute :posted, true
            logger.info "==== Super page not found found, Posted: #{current_page.uri.to_s}"
          end
        rescue StandardError => e
          logger.error "== Error: #{e.message}" unless e.message.include?('Connection refused') or e.message.include?('getaddrinfo') or e.message.include?('ContactForm')
        ensure
          begin
            logger.info "Reset Session!"
            error = false
            session.reset_session!
          rescue Selenium::WebDriver::Error::UnhandledAlertError => e
            logger.info "Webdriver Error: #{e.message}"
            error = true
          end while error
        end
      end
    end
  end
end