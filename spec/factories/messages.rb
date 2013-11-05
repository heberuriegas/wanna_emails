# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    subject { generate :words }
    text { generate :text }
    association :project
  end
end
