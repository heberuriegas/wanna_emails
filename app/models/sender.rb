class Sender < ActiveRecord::Base
  belongs_to :sender_entity

  alias_attribute :email, :user_name
end
