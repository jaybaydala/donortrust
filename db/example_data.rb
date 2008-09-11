module FixtureReplacement
  attributes_for :user do |u|
    password = String.random(9)
    
    u.display_name = String.random(6)
    u.first_name = String.random(7)
    u.last_name = String.random(8)
    u.login = "#{String.random(5)}user@example.com"
    u.password = password
    u.password_confirmation = password
    u.country = "USA"
    u.terms_of_use = "1"
	end

  attributes_for :contact do |c|
    c.first_name = String.random(11)
    c.last_name = String.random(12)
    c.phone_number = "(403) 555-7890"
    c.email_address = "#{String.random}contact@example.com"
	end

  attributes_for :deposit do |a|
	end

  attributes_for :gift do |g|
    email = "#{String.random}@example.com"
    to_email = "#{String.random(11)}@example.com"
    
    g.amount                = 25
    g.name                  = String.random
    g.email                 = email
    g.email_confirmation    = email
    g.to_name                  = String.random
    g.to_email              = to_email
    g.to_email_confirmation = to_email
    g.message               = String.random(25)
    g.send_email            = true
    g.send_at               = 5.minutes.from_now
    g.order                 = default_order
	end
  attributes_for :investment do |i|
    i.amount   = 100
    i.project  = default_project
    i.user     = default_user
    i.order    = default_order
	end
  attributes_for :order do |o|
    o.donor_type = Order.personal_donor
    o.country = "Canada"
	end


  attributes_for :group_gift do |a|
	end

  attributes_for :group_news do |a|
	end

  attributes_for :group_type do |a|
	end

  attributes_for :group_wall_message do |a|
	end

  attributes_for :group do |a|
	end

  attributes_for :membership do |a|
	end

  attributes_for :my_wishlist do |a|
	end

  attributes_for :partner_status do |ps|
    ps.name = String.random(13)
    ps.description = "Partner status description"
	end

  attributes_for :partner_type do |pt|
    pt.name = String.random(14)
    pt.description = "Description of Partner Type"
	end

  attributes_for :partner do |p|
    p.name = String.random(15)
    p.website = "www.google.ca"
    p.description = "Description for partner one"
    p.partner_type = default_partner_type
    p.partner_status = default_partner_status
    p.business_model = "test"
    p.funding_sources = "none"
    p.mission_statement = "mission"
    p.philosophy_dev = "none"
    p.note = "here is a note"
	end

  attributes_for :place_flickr_image do |a|
	end

  attributes_for :place_sector do |a|
	end

  attributes_for :place_type do |p|
    p.name = String.random(16)
	end

  attributes_for :place_you_tube_video do |a|
	end

  attributes_for :place do |p|
    p.name = String.random(17)
    p.description = "A place description"
    p.place_type = default_place_type
	end

  attributes_for :program do |p|
    p.name = String.random(18)
    p.note = "A Program note"
    p.contact = default_contact
	end

  attributes_for :project_flickr_image do |a|
	end

  attributes_for :project_status do |ps|
    ps.name = String.random(19)
    ps.description = String.random(25)
	end
	attributes_for :started_project_status, :from => :project_status do |ps|
	  ps.name = "Started"
  end

  attributes_for :project_you_tube_video do |a|
	end

  attributes_for :project do |p|
    p.name = String.random(20)
    p.description = "A project description"
    p.total_cost = 10000.00
    p.dollars_spent = 0.00
    p.expected_completion_date = Time.now.next_year.to_date.to_s(:db)
    p.target_start_date = Time.now.next_month.to_date.to_s(:db)
    p.target_end_date = Time.now.next_year.to_date.to_s(:db)
    p.place = default_place
    p.partner = default_partner
    p.project_status = default_started_project_status
    p.contact = default_contact
    p.program = default_program
  end

  attributes_for :tax_receipt do |a|
	end

  attributes_for :you_tube_video do |a|
	end
end