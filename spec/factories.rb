require 'factory_girl'

Factory.sequence :campaign_short_name do |n|
  "campaign_short_name_#{n}"
end

Factory.sequence :email do |n|
  "email#{n}@example.com"
end
Factory.define :user do |u|
  u.login { Factory.next(:email) }
  u.password 'Secret123'
  u.password_confirmation 'Secret123'
  u.terms_of_use '1'
  u.display_name { Faker::Name.name }
  u.country 'Canada'
end

Factory.define :campaign do |a|
  a.name { Faker::Lorem.words(5).join(' ') + " Campaign" }
  a.campaign_type { |ct| ct.association(:campaign_type) }
  a.creator {|u| u.association(:user) }
  a.description { Faker::Lorem.paragraph }
  a.country 'Canada'
  a.province 'AB'
  a.postalcode 'T2Y3N2'
  a.fundraising_goal '1000'
  a.short_name { Factory.next(:campaign_short_name) }
  a.start_date { Time.now + 1.day }
  a.event_date { Time.now + 15.days }
  a.raise_funds_till_date { Time.now + 30.days }
  a.allocate_funds_by_date { Time.now + 45.days }
end

Factory.define :campaign_type do |a|
  a.name { Faker::Lorem.words(5).join(' ') + " CampaignType" }
  a.has_teams { [true, false].rand }
end
