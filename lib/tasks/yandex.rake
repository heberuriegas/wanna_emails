# Execute with: 
# rake olx:post_messages["Asurela Santiago Posts",Olx,"http://www.olx.cl/servicios-cat-191",1-2,false]

require "capybara"
require "capybara/dsl"
begin
  require 'capybara-webkit'
rescue LoadError => e
  
end

namespace :yandex_accounts do

  desc "Generate data dummy for services"
  task :create, [:n] => :environment do |t, args|
    args.with_defaults n: 2

    logger = Logger.new("log/accounts/yandex_accounts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    Capybara.app_host = 'https://passport.yandex.com/registration/'
    Capybara.default_wait_time = 10
    Capybara.current_driver = :selenium

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      logger.info "New IP is #{agent.ip}"
    end

    (0...args[:n].to_i).each_with_index do |n,index|
      begin
        if Capybara.current_driver == :webkit
          page.driver.browser.clear_cookies
        elsif Capybara.current_driver == :selenium
          page.driver.browser.manage.delete_all_cookies
        end

        agent.switch_circuit

        visit "https://passport.yandex.com/registration"

        sender = Sender.new(generate: :CL, sender_entity: SenderEntity.find_by(name: 'Yandex'))

        fill_in 'firstname', with: sender.name.split(' ').first
        fill_in 'lastname', with: sender.name.split(' ').last
        fill_in 'login', with: sender.email.split('@').first
        sender.email = "#{sender.email.split('@').first}@yandex.com"
        fill_in 'password', with: sender.password
        fill_in 'password_confirm', with: sender.password
        select "Your mother's maiden name", from: 'hint_question_id'
        fill_in 'hint_answer', with: rand(10000)
        #fill_in 'phone_number', with: Sender.mobile_number
        check 'eula_accepted'
        debugger
        #find(:xpath, "//button[@class='submit']").click
        #sender.save! Set captcha and save manually
        logger.info "== Sender #{sender.email} created!"
      rescue Exception => e
        logger.error "== Error: #{e.message}"
      end
    end
  end

  desc "Send campaign in yahoo accounts"
  task :send_campaign, [:campaign_id,:country,:tor] => :environment do |t, args|
    args.with_defaults campaign_id: 1
    args.with_defaults language: 'cl'
    args.with_defaults tor: 'true'

    logger = Logger.new("log/accounts/yahoo_accounts.log")
    logger.info "=============================== Run #{DateTime.now.to_s}"

    sender_entity = case args[:country]
    when 'cl'
      SenderEntity.find_by(name: 'Yahoo Chile')
    else
      SenderEntity.find_by(name: 'Yahoo')
    end
    campaign = Campaign.find(args[:campaign_id])

    LOGIN_LIMIT = 1

    Capybara.app_host = 'http://mail.yahoo.com'
    Capybara.default_wait_time = 10
    Capybara.current_driver = :webkit

    include Capybara::DSL

    agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
      logger.info "New IP is #{agent.ip}"
    end if args[:tor] == 'true'

    i18n = {
      'ES' => {
        type_new: 'Nuevo',
        send: 'Enviar',
        sended: 'Mensaje enviado'
      },
      'EN' => {
        type_new: 'Compose',
        send: 'Send',
        sended: 'Message Sent'
      }
    }

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

        visit 'http://mail.yahoo.com' ; logger.info "Visit http://mail.yahoo.com"

        if has_xpath?("//input[@id='username']")
          sender = senders.sample
          raise("Not available senders") unless sender.present?
          count_login = 0
          begin
            logger.info "Try loggin with #{sender.email}"
            fill_in 'username', with: sender.email
            fill_in 'passwd', with: sender.password
            click_button '.save'
            count_login += 1 
            if count_login == 4
              sender.block!
              raise ("Sender #{sender.email} blocked!")
            end
          end while !has_no_xpath?("//input[@id='username']")

          logger.info "== Login with #{sender.email}"
        end

        message = message.sanitize(sender,email.recollection_pages.try(:sample))
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