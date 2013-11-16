FactoryGirl.define do
  sequence(:email) { Faker::Internet.email }
  sequence(:username) { Faker::Internet.user_name }
  sequence(:password) { SecureRandom.base64 }
  sequence(:ip_address) { Faker::Internet.ip_v4_address }

  sequence(:full_name) { Faker::Name.name }
  sequence(:first_name) { Faker::Name.first_name }
  sequence(:last_name) { Faker::Name.last_name }
  sequence(:address) { Faker::Address.street_address }
  sequence(:extended_address) { Faker::Address.secondary_address }
  sequence(:city) { Faker::Address.city }
  sequence(:zip_code) { Faker::Address.zip_code }
  sequence(:country) { Braintree::Address::CountryNames.sample.second }
  sequence(:latitude) { Faker::Address.latitude }
  sequence(:longitude) { Faker::Address.longitude }

  sequence(:text) { Faker::Lorem.paragraph(3) }
  sequence(:word) { Faker::Lorem.word }
  sequence(:words) { Faker::Lorem.words.join(' ') }

  sequence(:boolean) { rand(2).zero? }
  sequence(:boolean_most_true) { rand(4) > 0 }
  sequence(:boolean_most_false) { rand(4).zero? }

  sequence(:random_number) { rand(1000) + 1 }

  sequence(:domain) { "http://#{Faker::Internet.domain_name}" }
  sequence(:uri) { Faker::Internet.url }
  sequence(:language) { ['ES','EN'].sample }

  sequence(:date) { DateTime.now }
end