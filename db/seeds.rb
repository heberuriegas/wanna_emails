# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
# Environment variables (ENV['...']) can be set in the file config/application.yml.
# See http://railsapps.github.io/rails-environment-variables.html
puts 'ROLES'
YAML.load(ENV['ROLES']).each do |role|
  Role.find_or_create_by_name(role)
  puts 'role: ' << role
end
puts 'DEFAULT USERS'
user = User.find_or_create_by_email :name => ENV['ADMIN_NAME'].dup, :email => ENV['ADMIN_EMAIL'].dup, :password => ENV['ADMIN_PASSWORD'].dup, :password_confirmation => ENV['ADMIN_PASSWORD'].dup
puts 'user: ' << user.name
user.add_role :admin

senders = [
  {
    name: 'Gmail',
    address: 'smtp.gmail.com',
    port: 587,
    domain: 'gmail.com',
    authentication: 'plain',
    enable_starttls_auto: true,
    limit: 500
  },
  {
    name: "Yahoo",
    address: 'smtp.mail.yahoo.com',
    port: 587,
    domain: 'yahoo.com',
    authentication: 'plain',
    enable_starttls_auto: true,
    limit: 500
  },
  {
    name: "Yahoo Chile",
    address: 'smtp.mail.yahoo.com',
    port: 587,
    domain: 'yahoo.cl',
    authentication: 'plain',
    enable_starttls_auto: true,
    limit: 500
  }
]

senders.each do |sender|
  sender_entity = SenderEntity.where(name: sender[:name]).first_or_create
  sender_entity.update_attributes sender
end