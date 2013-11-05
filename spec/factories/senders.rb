# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :sender do
    name "MyString"
    sender_entity nil
    user_name "MyString"
    password "MyString"
    language "MyString"
    mail_sent 1
    blocked false
  end
end
