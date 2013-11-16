# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :phone do
    number { generate :random_number }
    association :recollection_page
  end
end
