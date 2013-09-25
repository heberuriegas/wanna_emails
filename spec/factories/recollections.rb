# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recollection do
    name "MyString"
    date "2013-09-21 18:40:15"
    latitude 1.5
    longitude 1.5
    goal 1
    user nil
  end
end
