# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name { generate(:full_name) }
    email { generate(:email) }
    password { @password = generate(:password) }
    password_confirmation { @password }
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end
