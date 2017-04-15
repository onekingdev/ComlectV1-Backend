# frozen_string_literal: true
# rubocop:disable Rails/Output
unless AdminUser.any?
  AdminUser.create!(
    email: 'admin@complect.co',
    password: 'password',
    password_confirmation: 'password',
    super_admin: true
  )
  puts "Admin credentials: admin@complect.co / password (login and change it)"
end

%w(USA Canada Africa Central\ America Asia South\ America Australasia Europe).each do |name|
  Jurisdiction.find_or_create_by! name: name
end

%w(Broker-Dealer Banking Fund\ Manager Investment\ Adviser Commodities\ Trader).each do |name|
  Industry.find_or_create_by! name: name
end

%w(sec finra cfdc nfa volckerrule doddfrank ria privateequity hedgefund mutualfund
   investmentcompany investmentcompanyact investmentadvisersact).each do |name|
  Skill.find_or_create_by! name: "##{name}"
end

load Rails.root.join('db', 'seeds', 'discourse.rb')

load Rails.root.join('db', 'seeds', 'sample_data.rb') if ENV['SAMPLE_DATA']
