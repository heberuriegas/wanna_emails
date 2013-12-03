# Execute with: 
# rake olx:post_messages["TradeGig Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require "capybara"
require "capybara/dsl"
begin
  require 'capybara-webkit'
rescue LoadError => e
  
end

namespace :google_accounts do

  desc "Generate data dummy for services"
  task :create, [:n,:language] => :environment do |t, args|
    args.with_defaults n: 10
    args.with_defaults language: 'cl'

    logger = Logger.new("log/accounts/google_accounts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

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

 desc "Send campaign in yahoo accounts"
  task :send_campaign, [:campaign_id,:tor] => :environment do |t, args|
    args.with_defaults campaign_id: 1
    args.with_defaults tor: 'true'

    logger = Logger.new("log/accounts/google_accounts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    sender_entity = SenderEntity.find_by(name: 'Gmail')
    campaign = Campaign.find(args[:campaign_id])

    LOGIN_LIMIT = 1

    login_page = 'http://accounts.google.com/ServiceLogin?service=mail&continue=https://mail.google.com/mail/&hl=en'
    Capybara.app_host = login_page
    Capybara.default_wait_time = 10
    Capybara.current_driver = :selenium

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      logger.info "New IP is #{agent.ip}"
    end if args[:tor] == 'true'

    messages = campaign.project.messages
    emails = campaign.emails_available
    sender = nil

    emails.each_with_index do |email,n|
      begin
        logger.info "Starts again..."
        
        message = messages.sample
        senders = Sender.availables.where(sender_entity: sender_entity)

        if n == 0 or n%LOGIN_LIMIT == LOGIN_LIMIT-1 or sender.try(:blocked?)
          logger.info "Clear cookies and change ip"
          if Capybara.current_driver == :webkit
            page.driver.browser.clear_cookies
          elsif Capybara.current_driver == :selenium
            page.driver.browser.manage.delete_all_cookies
          end

          agent.switch_circuit if args[:tor] == 'true'
        end

        visit login_page ; logger.info "Visit #{login_page}"

        if has_xpath?("//input[@id='Email']")
          sender = senders.sample
          raise("Not available senders") unless sender.present?
          count_login = 0
          begin
            logger.info "Try loggin with #{sender.email}"
            fill_in 'Email', with: sender.email
            fill_in 'Passwd', with: sender.password
            click_button 'signIn'
            count_login += 1 
            if count_login == 4
              sender.block!
              raise ("Sender #{sender.email} blocked!")
            end
          end while !has_no_xpath?("//input[@id='username']")

          logger.info "== Login with #{sender.email}"
        end

        if has_xpath?("//input[@id='phoneNumber']")
          fill_in 'phoneNumber', with: sender.phone
          click_button 'submitChallenge'
          click_button 'send-code-cancel-button'
        end

        message = message.sanitize(sender,email.recollection_pages.try(:sample))
        
=begin
        visit 'http://mail.yahoo.com' unless current_host.include?('mail.yahoo') ; logger.info "Visit http://mail.yahoo.com"
        visit("#{current_host}/neo/b/compose") ; logger.info "Visit basic version"

        #first(:button, i18n[sender.language][:type_new]).click ; logger.info "Click new email"
        
        fill_in 'to', with: email.address ; logger.info "Fill #{email.address} to"
        #address = "cristobaljimenez711+#{rand(100)}@gmail.com, heber.fernando+#{rand(100)}@gmail.com"
        #fill_in 'to', with: address ; logger.info "Fill #{address} to"
        fill_in 'Subj', with: message.subject ; logger.info "Fill subject"
        fill_in 'Content', with: message.text ; logger.info "Fill body"
        click_button i18n[sender.language][:send]
        sleep 5
        if has_content?(i18n[sender.language][:sended])
          SentEmail.create(campaign_id: campaign.id, sender_id: sender.id, message_id: message.id, email_id: email.id)
          logger.info "==== Email sended."
        end
=end
      rescue Exception => e
        break if e.message == 'Not available senders'
        logger.error "== Error: #{e.message}"

        if Capybara.current_driver == :webkit
          page.driver.browser.clear_cookies
        elsif Capybara.current_driver == :selenium
          page.driver.browser.manage.delete_all_cookies
        end

        agent.switch_circuit if args[:tor] == 'true'
      end
    end
  end
end