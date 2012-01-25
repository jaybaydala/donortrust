require 'factory_girl'
require 'faker'

Factory.sequence :email do |n|
  "email#{n}@example.com"
end

Factory.sequence :campaign_short_name do |n|
  "campaign_short_name_#{n}"
end

Factory.define :authentication do |a|
  a.user {|u| u.association(:user) }
  providers = %w(facebook twitter)
  a.provider { providers[rand(providers.size)] }
  a.uid "1234567890"
  a.token "120975612957171-98|10fbe127b6e5759ba86ec26d.1-7dud923oe397642366|F6j8tWNKHYJMpJ5Ug5EVreYt5VY"
end

Factory.define :campaign do |a|
  a.email { Faker::Internet.email }
  a.name { Faker::Company.bs + " Campaign" }
  a.campaign_type { |ct| ct.association(:campaign_type) }
  a.creator {|u| u.association(:user) }
  a.description { Faker::Lorem.paragraph }
  a.country 'Canada'
  a.province 'AB'
  a.postalcode 'T2Y3N2'
  a.fundraising_goal 1000
  a.allow_multiple_teams true
  a.short_name { Factory.next(:campaign_short_name) }
  a.start_date { 1.week.ago }
  a.event_date { 1.month.from_now }
  a.raise_funds_till_date { 2.months.from_now }
  a.allocate_funds_by_date { 3.months.from_now }
end

Factory.define :campaign_type do |a|
  a.name { Faker::Lorem.words(6).join(' ') + " CampaignType" }
  a.has_teams { [true, false].rand }
end

Factory.define :cart do |c|
end

Factory.define :cart_line_item do |c|
  c.cart {|c| c.association(:cart) }
  c.item { [ Factory.build(:investment), Factory.build(:gift) ].rand }
end

Factory.define :contact do |c|
  c.first_name { Faker::Name.first_name }
  c.last_name { Faker::Name.last_name }
end

Factory.define :deposit do |d|
  d.amount 100
  d.association :user, :factory => :user
end

Factory.define :feedback do |f|
  f.name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  f.email { Faker::Internet.email }
  f.subject { Faker::Lorem.sentence }
  f.message { Faker::Lorem.paragraph }
end

Factory.define :friendship do |f|
  f.association :user, :factory => :user
  f.association :friend, :factory => :user
  f.status false
end

Factory.define :gift do |g|
  email = Faker::Internet.email
  to_email = Faker::Internet.email
  g.amount 100
  g.name "John Sender"
  g.to_name "John Receiver"
  g.email { email }
  g.email_confirmation { email }
  g.to_email { to_email }
  g.to_email_confirmation { to_email }
  g.send_email "yes"
  g.send_at { 1.day.from_now }
end

Factory.define :iend_profile do |i|
  i.association :user, :factory => :user
end

Factory.define :profile do |i|
  i.association :user, :factory => :user
end

Factory.define :investment do |i|
  i.amount 100
  i.association :project#, :factory => :project
end


Factory.define :order do |o|
  o.cart {|c| c.association(:cart) }
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


Factory.sequence :participant_short_name do |n|
  "participant_short_name_#{n}"
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

Factory.define :partner do |p|
  p.name { "#{Faker::Lorem.words(3).join(" ")} Partner"}
  p.description "Partner description"
  p.association :partner_status
end

Factory.sequence :partner_status_name do |n|
  "PartnerStatusName#{n}"
end

Factory.define :partner_status do |p|
  p.name { Factory.next(:partner_status_name) }
  p.description "Partner Status Description"
end

Factory.define :place do |p|
  p.name { "#{Faker::Lorem.words(6).join(" ")} Place"}
  p.association :place_type
end

Factory.define :place_type do |p|
  p.name { "#{Faker::Lorem.words(6).join(" ")} PlaceType"}
end

Factory.define :program do |p|
  p.name { "#{Faker::Lorem.words(6).join(" ")} Program"}
  p.association :contact
end

Factory.define :project do |p|
  p.name { "#{Faker::Lorem.words(6).join(" ")} Project"}
  p.target_start_date Time.now
  p.total_cost 25000
  p.association :partner
  p.association :place
  p.association :program
  p.project_status { ProjectStatus.active || ProjectStatus.create(:name => "Active", :description => "Active Project") }
  p.slug nil
end

Factory.define :project_flickr_image do |p|
  p.association :project
  p.photo_id 3700894878
end

Factory.define :admin_project, :class => Project do |p|
  p.slug "admin"
  p.name "Admin Project"
  p.target_start_date 1.year.ago
  p.total_cost 10000000
  p.association :partner
  p.association :place
  p.association :program
  p.project_status { ProjectStatus.active || Factory(:project_status, :name => "Active") }
end

Factory.define :unallocated_project, :class => Project do |p|
  p.slug "unallocated"
  p.name "Unallocated Project"
  p.target_start_date 1.year.ago
  p.total_cost 10000000
  p.association :partner
  p.association :place
  p.association :program
  p.project_status { ProjectStatus.active || ProjectStatus.create(:name => "Active", :description => "Active Project") }
end

Factory.define :project_status do |p|
  p.name { "#{Faker::Lorem.words(6).join(" ")} Project Status"}
  p.description { Faker::Lorem.sentence }
end

Factory.define :project_status_active, :class => ProjectStatus do |p|
  p.name "Active"
  p.description { Faker::Lorem.sentence }
end

Factory.define :project_status_completed, :class => ProjectStatus do |p|
  p.name "Completed"
  p.description { Faker::Lorem.sentence }
end

Factory.define :subscription do |s|
  s.donor_type "personal"
  s.first_name { Faker::Name.first_name }
  s.last_name { Faker::Name.last_name }
  s.email { Faker::Internet.email }
  s.address { Faker::Address.street_address }
  s.city 'Calgary'
  s.province 'AB'
  s.postal_code 'T2Y 3N2'
  s.country 'Canada'
  s.begin_date { Date.today }
  s.schedule_type "MONTHLY"
  s.schedule_date {|s| s.begin_date.day }
  s.end_date {|s| s.begin_date + 10.years }
  s.card_number 4111111111111111
  s.expiry_month "01"
  s.expiry_year Date.today.year + 1
  s.cardholder_name { Faker::Name.name }
  s.customer_code "12345"
  s.amount 5
  s.cvv 989
end

Factory.define :subscription_line_item do |s|
  Project.admin_project || Factory(:admin_project)
  s.item_type "Investment"
  s.item_attributes { Factory.build(:investment, :amount => 5, :project => Project.admin_project).attributes }
  s.association :subscription
end

Factory.sequence :team_short_name do |n|
  "team_short_name_#{n}"
end
Factory.define :team do |t|
  t.name { "#{Faker::Name.name} Team" }
  t.short_name { Factory.next(:team_short_name) }
  t.contact_email { Faker::Internet.email }
  t.description { Faker::Lorem.paragraph }
  t.goal 500
  t.goal_currency "CAD"
  t.association :campaign, :factory => :campaign
  t.association :user, :factory => :user
  t.pending false
  t.ok_to_contact true
  t.require_authorization false
end

Factory.define :user do |u|
  u.login { Factory.next(:email) }
  u.password 'Secret123'
  u.password_confirmation 'Secret123'
  u.under_thirteen false
  u.terms_of_use '1'
  u.image { u.paperclip_fixture("user", "image", "jpg") }
  u.display_name { Faker::Name.name }
  u.country 'Canada' #{ ["Canada", "United States of America"].rand }
end

Factory.define :country, :class => Place do |p|
  p.name { "France" }
  p.place_type_id 2
end

Factory.define :geolocation do |g|
  g.ip_address '69.60.70.50'
end

Factory.define :share do |s|
  s.name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  s.email { Faker::Internet.email }
  s.to_email { Faker::Internet.email }
end

Factory.define :group_type do |gt|
  gt.name { Faker::Name.name }
end

Factory.define :group do |g|
  g.name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  g.association :group_type, :factory => :group_type
  g.private { false }
end

Factory.define :membership do |m|
  m.membership_type Membership.member
end

Factory.define :invitation do |s|
  s.to_name { "#{Faker::Name.first_name} #{Faker::Name.last_name}" }
  s.to_email { Faker::Internet.email }
  s.association :user, :factory => :user
end

Factory.define :upowered_email_subscribe do |u|
  u.email { Faker::Internet.email }
  u.code "12345"
end

Factory.define :tax_receipt do |t|
  t.first_name  { Faker::Name.first_name }
  t.last_name   { Faker::Name.last_name }
  t.address     { Faker::Address.street_address }
  t.city        { Faker::Address.city }
  t.postal_code '12909'
  t.province    'Ottawa'
  t.country     'Canada'
  t.email       { Faker::Internet.email }
end
