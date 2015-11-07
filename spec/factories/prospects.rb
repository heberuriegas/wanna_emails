# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :prospect do
    name "MyString"
    address "MyString"
    hours "MyString"
    category nil
    recollection_page nil
  end
end
