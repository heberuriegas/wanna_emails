# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

namespace :vivastreet do

  desc "Generate data dummy for services"
  task :post_messages, [:project, :recollection, :url, :pages, :tor] => :environment do |t, args|
    args.with_defaults project: 'TradeGig Santiago Posts'
    args.with_defaults recollection: 'Vivastreet'
    args.with_defaults url: 'http://www.vivastreet.cl/trabajos-independientes'
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
    senders = Sender.where(language: 'ES').where('id between 33 and 38')

    email_recollector = EmailRecollector.new

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3

        visit("#{args[:url]}/t+#{n}")
        logger.info "==== Visit Page: #{args[:url]}/t+#{n}"
        services_urls = all(:xpath, "//a[@class='classified-link']").map{ |a| a[:href] }

        services_urls.each_with_index do |service_url,index|
          begin
            service_page = Page.where(uri: service_url).first_or_create

            unless service_page.posted == true
                sender = senders[index % senders.count]
                visit 'http://www.vivastreet.cl/login.php'
                fill_in 'email', with: sender.email
                fill_in 'password', with: sender.password
                click_button 'Entrar'

                visit(service_url)
                logger.info "Visit: #{service_url}"
                
                contact_link = all(:xpath, "//span[@class='kiwii-xxdark-gray']//a")
                if contact_link.present?
                    contact_url = contact_link.first[:href]
                    contact_page = Page.where(uri: contact_url).first_or_create
                    recollection_page_contact = RecollectionPage.where(recollection_id: recollection.id, page_id: contact_page.id).first_or_create
                else
                    contact_page = 'passed'
                end

                recollection_page_emails = RecollectionPage.where(recollection_id: recollection.id, page_id: service_page.id).first_or_create
                email_recollector.recollect_emails body: body, title: title, uri: URI.parse(service_url)
                #phone_number = all(:xpath, "//li[@class='phone']//strong").map{|t| t.text}.first
                recollection.save_emails_and_pages email_recollector.recollections
                #recollection_page_emails.phones << Phone.where(number: phone_number) unless recollection_page_emails.phones.pluck(:number).include?(phone_number)

                if contact_page == 'passed' or contact_page.posted == false
                    fill_in 'vs_contact_message', with: project.messages.sample.text.gsub(':name', sender.name).gsub(':recollection_name', recollection.name).gsub(':url', service_url)
                    click_button 'vs_contact_submit'
                    logger.info "Click: \"Send message button\" button"
                    logger.info "== Posted: #{service_url}"
                    service_page.update_attribute :posted, true
                    agent.switch_circuit
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
      rescue Exception => e
        logger.error "== Error: #{e.message}"
        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end
end