# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

namespace :adoos do

  desc "Generate data dummy for services"
  task :post_messages, [:project, :recollection, :url, :pages, :tor] => :environment do |t, args|
    args.with_defaults project: 'TradeGig Santiago Posts'
    args.with_defaults recollection: 'Adoos'
    args.with_defaults url: 'http://www.adoos.cl/l/ser'
    args.with_defaults pages: '1-2'
    args.with_defaults tor: 'true'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    pages = args[:pages].split('-')

    require "capybara"
    require "capybara/dsl"
    require "capybara-webkit"

    Capybara.app_host = args[:url]
    Capybara.default_wait_time = 10
    Capybara.current_driver = :selenium

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      sleep 5
      logger.info "New IP is #{agent.ip}"
    end if args[:tor] == 'true'
    
    project = Project.where(name: args[:project]).first_or_create
    throw("You need at least 1 message.") unless project.messages.present?
    throw("You need at least 1 sender.") unless Sender.where(language: 'ES').present?

    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create
    recollection.update_attribute :unique_pages, true if recollection.unique_pages == false
    email_recollector = EmailRecollector.new

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3
        visit("#{args[:url]}-page#{n}")
        logger.info "==== Visit Page: #{args[:url]}-page#{n}"
        services_urls = all(:xpath, "//table[@id='adoos-ads-list']//h4//a").map{ |a| a[:href] }
        services_urls.each do |service_url|
          begin
            service_page = Page.where(uri: service_url).first_or_create

            unless service_page.posted == true
                visit(service_url)
                logger.info "Visit: #{service_url}"

                sender = Sender.new(generate: :ES)
                recollection_page_emails = RecollectionPage.where(recollection_id: recollection.id, page_id: service_page.id).first_or_create
                email_recollector.recollect_emails body: body, title: title, uri: URI.parse(service_url)
                phone_number = all(:xpath, "//span[@class='adoos-phone-number']//b").try(:first).try(:text)
                
                click_button 'adoos-contact-button'
                fill_in 'message', with: project.messages.sample.text.gsub(':name', sender.name).gsub(':recollection_name', recollection.name).gsub(':url', service_url)
                fill_in 'name_from', with: sender.name
                fill_in 'email_from', with: sender.email
                click_button 'adoos-contact-button-submit'
                
                logger.info "== Posted: #{contact_url}"
                contact_page.update_attribute :posted, true
                
                recollection.save_emails_and_pages email_recollector.recollections
                recollection_page_emails.phones << Phone.where(number: phone_number) unless recollection_page_emails.phones.pluck(:number).include?(phone_number)
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
end