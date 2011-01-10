require 'factory_girl'

Factory.sequence :campaign_short_name do |n|
  "campaign_short_name_#{n}"
end

Factory.sequence :participant_short_name do |n|
  "participant_short_name_#{n}"
end
Factory.sequence :team_short_name do |n|
  "team_short_name_#{n}"
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
  a.email { Faker::Internet.email }
  a.name { Faker::Lorem.words(5).join(' ') + " Campaign" }
  a.campaign_type { |ct| ct.association(:campaign_type) }
  a.creator {|u| u.association(:user) }
  a.description { Faker::Lorem.paragraph }
  a.country 'Canada'
  a.province 'AB'
  a.postalcode 'T2Y3N2'
  a.fundraising_goal 1000
  a.allow_multiple_teams false
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

Factory.define :deposit do |d|
  d.amount 100
  d.association :user, :factory => :user
end

Factory.define :order do |o|
  o.first_name { Faker::Name.first_name }
  o.last_name { Faker::Name.last_name }
  o.email { Faker::Internet.email }
  o.address { Faker::Address.street_address }
  o.city 'Calgary'
  o.province 'AB'
  o.postal_code 'T2Y 3N2'
  o.country 'Canada'
  o.total 100
  o.credit_card_payment 100
  o.card_number 1
  o.expiry_month 1
  o.expiry_year Date.today.year + 1
  o.cardholder_name { Faker::Name.name }
  o.cvv 989
end

Factory.define :participant do |p|
  p.association :team, :factory => :team
  p.association :user, :factory => :user
  p.short_name { Factory.next(:participant_short_name) }
  p.pending false
  p.private false
  p.about_participant { Faker::Lorem.paragraph }
  p.goal 100
  p.active true
end

Factory.define :team do |t|
  t.association :campaign, :factory => :campaign
  t.association :user, :factory => :user
  t.pending false
  t.ok_to_contact true
  t.require_authorization false
  t.name { "#{Faker::Name.name} Team" }
  t.contact_email { Faker::Internet.email }
  t.short_name { Factory.next(:team_short_name) }
  t.description { Faker::Lorem.paragraph }
  t.goal 500
  t.goal_currency "CAD"
end