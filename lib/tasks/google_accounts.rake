# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

namespace :google_accounts do

  desc "Generate data dummy for services"
  task :create, [:n,:language] => :environment do |t, args|
    args.with_defaults n: 10
    args.with_defaults language: 'cl'

    logger = Logger.new("log/accounts/google_accounts.log")
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
        if page.driver.browser.respond_to?(:clear_cookies)
          page.driver.browser.clear_cookies
        elsif page.driver.browser.respond_to?(:manage) and page.driver.browser.manage.respond_to?(:delete_all_cookies)
          page.driver.browser.manage.delete_all_cookies
        else
          raise "Don't know how to clear cookies. Weird driver?"
        end

        agent.switch_circuit

        visit "https://gmail.com"
        click_link 'gmail-create-account'
        
        sender = Sender.new(generate: :ES, sender_entity: SenderEntity.find_by(name: 'Gmail'))
        fill_in 'FirstName', with: sender.name.split(' ').first
        fill_in 'LastName', with: sender.name.split(' ').last
        fill_in 'GmailAddress', with: sender.email.split('@').first
        sender.email = "#{sender.email.split('@').first}@gmail.com"
        fill_in 'Passwd', with: sender.password
        fill_in 'PasswdAgain', with: sender.password
        find(:xpath, "//span[@id='BirthMonth']//div[@class='goog-inline-block goog-flat-menu-button-dropdown']").click
        sleep 2
        find(:xpath, "//div[@id=':#{rand(11)}']//div").click
        fill_in 'BirthDay', with: rand(29)+1
        fill_in 'BirthYear', with: rand(20)+1970
        find(:xpath, "//div[@id='Gender']//div[@class='goog-inline-block goog-flat-menu-button jfk-select']").click
        sleep 1
        find(:xpath, "//div[@id=':e']//div").click
        fill_in 'RecoveryPhoneNumber', with: Sender.mobile_number(prefix: true)
        fill_in 'RecoveryEmailAddress', with: "#{Sender.last.user_name}+#{rand(100)}@gmail.com"
        check('TermsOfService')

        debugger
        #sender.save! Set captcha and save manually
        logger.info "== Sender #{sender.email} created!" if sender.persisted?
      rescue Exception => e
        logger.error "== Error: #{e.message}"
      end
    end

  end
end