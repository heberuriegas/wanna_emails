class SenderEntity < ActiveRecord::Base
  has_many :senders

  def configuration_hash sender=nil
    user_name = sender.present? ? sender.user_name : self.user_name
    password = sender.present? ? sender.password : self.password
    {
      address: self.address,
      authentication: self.authentication.to_sym,
      user_name: user_name,
      password: password,
      domain: self.domain,
      port: self.port,
      enable_starttls_auto: self.enable_starttls_auto
    }
  end

end
