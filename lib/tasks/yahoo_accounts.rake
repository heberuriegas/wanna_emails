# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

namespace :yahoo_accounts do

  desc "Generate data dummy for services"
  task :create, [:n,:language] => :environment do |t, args|
    args.with_defaults n: 2
    args.with_defaults language: 'cl'

    logger = Logger.new("log/accounts/yahoo_accounts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    require "capybara"
    require "capybara/dsl"
    require "capybara-webkit"

    Capybara.app_host = args[:url]
    Capybara.default_wait_time = 10
    Capybara.current_driver = :selenium

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      sleep 10
      logger.info "New IP is #{agent.ip}"
    end

    (0...args[:n].to_i).each_with_index do |n,index|
      begin
        visit "https://edit.yahoo.com/registration?intl=#{args[:language]}"

        sender = Sender.new(generate: :ES, sender_entity: SenderEntity.find_by(name: 'Yahoo'))

        fill_in 'firstname', with: sender.name.split(' ').first
        fill_in 'secondname', with: sender.name.split(' ').last
        fill_in 'yahooid', with: sender.email.split('@').first
        sender.email = "#{sender.email.split('@').first}@yahoo.cl"
        fill_in 'password', with: sender.password
        fill_in 'mobileNumber', with: Sender.mobile_number
        find(:xpath, "//select[@id='day']//option[@value='#{rand(29)+1}']").click
        sleep 4
        find(:xpath, "//select[@id='month']//option[@value='#{rand(11)+1}']").click
        sleep 4
        find(:xpath, "//select[@id='year']//option[@value='#{rand(20)+1970}']").click
        sleep 4
        find(:xpath, "//label[@for='#{['male','female'].sample}']").click
        
        find(:xpath, "//button[@class='submit']").click
        debugger
        #sender.save! Set captcha and save manually
        logger.info "== Sender #{sender.email} created!"
      rescue Exception => e
        logger.error "== Error: #{e.message}"
      ensure
        if Capybara.current_driver == :webkit
          page.driver.browser.clear_cookies
        elsif Capybara.current_driver == :selenium
          page.driver.browser.manage.delete_all_cookies
        end

        agent.switch_circuit
      end
    end

  end
end