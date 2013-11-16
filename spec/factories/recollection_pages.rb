# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recollection_page do
    association :recollection
    association :page
    emails_count { generate :random_number }
  end
end
