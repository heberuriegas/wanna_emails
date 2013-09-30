# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :page do
    host { generate :domain }
    uri { generate :uri }
  end
end
