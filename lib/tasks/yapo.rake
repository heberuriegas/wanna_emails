# Execute with: 
# rake olx:post_messages["Asurela Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require "capybara"
require "capybara/dsl"
begin
  require 'capybara-webkit'
rescue LoadError => e
  
end

namespace :yapo do

  desc "Generate data dummy for services"
  task :post_messages, [:project, :recollection, :url, :pages, :tor] => :environment do |t, args|
    args.with_defaults project: 'Asurela Santiago Posts'
    args.with_defaults recollection: 'Yapo'
    args.with_defaults url: 'http://www.yapo.cl/region_metropolitana/servicios_negocios_empleo?ca=15_s&cg=7000'
    args.with_defaults pages: '1-2'
    args.with_defaults tor: 'true'

    logger = Logger.new("log/posts/#{args[:recollection].underscore.gsub(' ','_')}.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    pages = args[:pages].split('-')

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
    #throw("You need at least 1 sender.") unless Sender.where(language: 'ES').present?

    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create
    recollection.update_attribute :unique_pages, true if recollection.unique_pages == false

    email_recollector = EmailRecollector.new

    (pages[0].to_i...pages[1].to_i).each_with_index do |n,index|
      begin
        agent.switch_circuit if index % 3 == 3
        visit("#{args[:url]}&o=#{n}")
        logger.info "==== Visit Page: #{args[:url]}&o=#{n}"
        services_urls = all(:xpath, "//a[@class='title']").map{ |a| a[:href] }
        services_urls.each do |service_url|
          begin
            visit(service_url)
            logger.info "Visit: #{service_url}"

            recollection_page_emails = RecollectionPage.where(recollection_id: recollection.id, page_id: Page.where(uri: service_url).first_or_create.id).first_or_create
            email_recollector.recollect_emails body: body, title: title, uri: URI.parse(service_url)
            #phone_number = all(:xpath, "//li[@class='phone']//strong").map{|t| t.text}.first

            contact_url = find(:xpath, "//a[@id='ar_link']")[:href]
            #contact_url = "#{contact_path}?b=561595831"
            contact_page = Page.where(uri: current_url).first_or_create
            unless contact_page.posted == true                
                recollection_page = RecollectionPage.where(recollection_id: recollection.id, page_id: contact_page.id).first_or_create
                
                sender = Sender.new(generate: :CL)
                visit contact_url
                logger.info "Visit: #{contact_url}"
                fill_in 'adreply_body', with: project.messages.sample.text.gsub(':name', sender.name).gsub(':recollection_name', recollection.name).gsub(':url', service_url)
                fill_in 'name', with: sender.name
                fill_in 'email', with: sender.email
                click_button('Enviar')
                logger.info "== Posted: #{contact_url}"
                contact_page.update_attribute :posted, true
            
                recollection.save_emails_and_pages email_recollector.recollections
                #recollection_page_emails.phones << Phone.where(number: phone_number) unless recollection_page_emails.phones.pluck(:number).include?(phone_number)
                sleep 3
            end
          rescue Exception => e
            logger.error "== Error: #{e.message}"
            agent.switch_circuit if args[:tor] == 'true'
          ensure
            reset_session!
          end    
        end
      rescue Exception => e
        logger.error "== Error: #{e.message}"
        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end
end