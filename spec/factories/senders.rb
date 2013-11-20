# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sender do
    name { generate :full_name }
    association :sender_entity
    email { generate :email }
    password { generate :password }
    language { generate :language }
    mail_sent { generate :random_number }
    blocked { generate :boolean }
    last_blocked_at { generate :date }
  end
end
