class UserRole < ActiveRecord::Base
  belongs_to :user
  
  validates_inclusion_of :fieldname, 
    :in => %w(busAdmin,partnerAdmin,teamAdmin,campaignAdmin,projectAdmin)
end
