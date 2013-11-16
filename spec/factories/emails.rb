# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email do
    address { generate :email }
    last_sent_at { generate :date }
  end
end
