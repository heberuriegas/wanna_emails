# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recollection do
    name { generate :word }
    date { generate :date }
    latitude 100.0
    longitude -100.0
    goal { generate :random_number }
    association :user
    association :project
  end
end
