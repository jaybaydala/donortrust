require 'machinist/active_record'
require 'faker'

# Semi-static data
PlaceType.blueprint do
  name { "Country" }
end
Place.blueprint do
  name { "Canada" }
  place_type { PlaceType.make :name => "Country" }
end
# User-related
User.blueprint do
  login { Faker::Internet.email }
  password { "secret" }
  password_confirmation { "secret" }
  display_name { Faker::Name.name }
  country { ["Canada", "United States of America"].rand }
  terms_of_use { true }
end

# Campaign-related
Campaign.blueprint do
  name { Faker::Company.bs }
  start_date { 1.week.ago }
  event_date { 1.month.from_now }
  raise_funds_till_date { 3.weeks.from_now }
  allocate_funds_by_date { 1.month.from_now - 1.day }
  description { Faker::Lorem.paragraph }
  campaign_type
  fundraising_goal { 10000 }
  creator { User.make(:terms_of_use => true)}
  short_name { Faker::Company.catch_phrase.downcase.gsub(/[\s-]/, "_") }
  allow_multiple_teams { true }
end
CampaignType.blueprint do
  name { "Default" }
end
Team.blueprint do 
  name { Faker::Company.name }
  short_name { Faker::Company.catch_phrase.downcase.gsub(/[\s-]/, "_") }
  contact_email { Faker::Internet.email }
  description { Faker::Lorem.paragraph }
  goal { 1000 }
  leader
end