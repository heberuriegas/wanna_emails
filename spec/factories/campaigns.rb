# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :campaign do
    name { generate :text }
    state 0
    starts_at { generate :date }
    ends_at { generate :date }
    report { generate :words }
    association :project
    association :user
  end
end
