# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sent_email do
    association :campaign
    association :email
    associaation :sender
    association :messate
  end
end
