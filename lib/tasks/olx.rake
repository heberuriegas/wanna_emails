namespace :olx do
  desc "Generate data dummy for services"
  task :post_messages, [:project, :recollection, :url, :pages, :tor] => :environment do |t, args|
    args.with_defaults project: 'TradeGig'
    args.with_defaults recollection: 'Olx'
    args.with_defaults url: 'http://www.olx.cl/servicios-cat-191'
    args.with_defaults pages: '1-10'
    args.with_defaults tor: nil

    pages = args[:pages].split('-')

    require "capybara"
    require "capybara/dsl"
    require "capybara-webkit"

    Capybara.app_host = args[:url]
    Capybara.default_wait_time = 10
    Capybara.current_driver = :webkit

    contact_path = 'http://olx.cl/contact_seller.php'

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      sleep 5
      puts "New IP is #{agent.ip}"
    end if args[:tor] == 'true'
    
    project = Project.where(name: args[:project]).first_or_create
    throw("You need at least 1 message.") unless project.messages.present?
    throw("You need at least 1 sender.") unless Sender.where(language: 'ES').present?

    recollection = Recollection.where(name: args[:recollection], project_id: project.id).first_or_create

    email_recollector = EmailRecollector.new

    (pages[0].to_i...pages[1].to_i).each do |n|
      begin
        puts "== Visit: #{args[:url]}-p-#{n}"
        visit("#{args[:url]}-p-#{n}")
        pages = all(:xpath, "//div[@id='itemListContent']//h3//a").map{ |a| a[:href] }
        pages.each do |page|
          begin
            sender = Sender.where(language: 'ES').sample
            puts "== Visit: #{page}"
            visit(page)

            recollection_page = RecollectionPage.where(recollection_id: recollection.id, page_id: Page.where(uri: page).first_or_create.id).first_or_create
            email_recollector.recollect_emails body: body, title: title, uri: URI.parse(page)
            phone_number = all(:xpath, "//li[@class='phone']//strong").map{|t| t.text}.first
            contact_page = "#{contact_path}?b=#{current_url.split('-').last}"
            visit contact_page
            fill_in 'comment', with: project.messages.sample.text
            fill_in 'name', with: sender.name
            fill_in 'email', with: sender.email
            # Send message
            recollection.save_emails_and_pages email_recollector.recollections
            recollection_page.phones << Phone.where(number: phone_number) unless recollection_page.phones.pluck(:number).include?(phone_number)
            sleep 3
          rescue Exception => e
            puts "== Error: #{e.message}"
            agent.switch_circuit if args[:tor] == 'true'
          end    
        end
      rescue Exception => e
        puts "== Error: #{e.message}"
        agent.switch_circuit unless args[:tor].nil?
      end
    end
  end
end