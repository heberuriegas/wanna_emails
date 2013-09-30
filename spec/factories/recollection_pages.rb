# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recollection_page do
    recollection nil
    page nil
    emails_count 1
  end
end
