# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

namespace :skillpages do

  desc "Generate data dummy for services"
  task :post_messages, [:project, :recollection, :url, :pages, :tor] => :environment do |t, args|
    args.with_defaults project: 'TradeGig Santiago Posts'
    args.with_defaults recollection: 'Skillpages'
    args.with_defaults url: 'http://www.skillpages.com/listing/skills/all/chile/0/0/0/0/'
    args.with_defaults pages: '1-2'
    args.with_defaults tor: 'true'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    pages = args[:pages].split('-')

    require "capybara"
    require "capybara/dsl"
    require "capybara-webkit"

    Capybara.app_host = args[:url]
    Capybara.default_wait_time = 20
    Capybara.current_driver = :selenium

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      sleep 10
      logger.info "New IP is #{agent.ip}"
    end if args[:tor] == 'true'
    
    project = Project.where(name: args[:project]).first_or_create
    throw("You need at least 1 message.") unless project.messages.present?
    throw("You need at least 1 sender.") unless Sender.where(language: 'ES').present?

    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create
    recollection.update_attribute :unique_pages, true if recollection.unique_pages == false
    senders = Sender.where(language: 'ES')

    email_recollector = EmailRecollector.new

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3

        sender = senders[index % senders.count]
        visit 'http://www.skillpages.com/i/login'
        fill_in 'Email', with: sender.email
        fill_in 'Password', with: sender.password
        click_button 'Login'
        sleep 7

        visit("#{args[:url]}/#{n}")
        logger.info "==== Visit Page: #{args[:url]}/t+#{n}"
        services_rows = all(:xpath, "//li[@class='liResult ']")

        services_rows.each_with_index do |service_row,index|
          begin
            service_url = service_row.find(:xpath, ".//header//h3//a")[:href]
            service_page = Page.where(uri: service_url).first_or_create
            
            unless service_page.posted == true
                service_row.hover
                service_row.find(:xpath, ".//input[@value='Message']").click

                recollection_page_emails = RecollectionPage.where(recollection_id: recollection.id, page_id: service_page.id).first_or_create
                email_recollector.recollect_emails body: body, title: title, uri: URI.parse(service_url)
                #phone_number = all(:xpath, "//li[@class='phone']//strong").map{|t| t.text}.first
                recollection.save_emails_and_pages email_recollector.recollections
                #recollection_page_emails.phones << Phone.where(number: phone_number) unless recollection_page_emails.phones.pluck(:number).include?(phone_number)
=begin
                fill_in 'Body', with: project.messages.sample.text.gsub(':name', sender.name).gsub(':recollection_name', recollection.name).gsub(':url', service_url)
                click_button 'Send'
                logger.info "Click: \"Send message button\" button"
                logger.info "== Posted: #{service_url}"
                service_page.update_attribute :posted, true
                sleep 7
=end
            end
          rescue Exception => e
            logger.error "== Error: #{e.message}"
            agent.switch_circuit if args[:tor] == 'true'
          end    
        end
        if Capybara.current_driver == :webkit
            page.driver.browser.clear_cookies
        elsif Capybara.current_driver == :selenium
            page.driver.browser.manage.delete_all_cookies
        end
      rescue Exception => e
        logger.error "== Error: #{e.message}"
        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end
end