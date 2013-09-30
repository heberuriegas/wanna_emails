# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :recollection do
    name "Monterrey, Nuevo León"
    date "2013-09-21 18:40:15"
    latitude 100.0
    longitude -100.0
    goal 1
    association :user
    association :project
  end
end
