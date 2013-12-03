module WannaEmails
  module Proxy
    def self.included(base)
      
      require "capybara"
      require "capybara/dsl"
      begin
        require 'capybara-webkit'
      rescue LoadError => e
        
      end

      Capybara.default_wait_time = 10
      Capybara.current_driver = :selenium

      include Capybara::DSL

      agent = TorPrivoxy::Agent.new host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true do |agent|
        logger.info "New IP is #{agent.ip}"
      end
      
  end
end 