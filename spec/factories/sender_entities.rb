# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sender_entity do
    authentication 'plain'
    enable_starttls_auto true
    limit { generate :random_number }
    full_user_name { generate :boolean }

    factory :sender_entity_gmail do
        name 'Gmail'
        address 'smtp.gmail.com'
        port 587
        domain 'gmail.com'
    end

    factory :sender_entity_yahoo do
        name 'Yahoo'
        address 'smtp.mail.yahoo.com'
        port 465
        domain 'yahoo.com'
    end
  end
end
