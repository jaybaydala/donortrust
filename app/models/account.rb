class Account < ActiveRecord::Base
  
  validates_presence_of :first_name, :last_name, :email
  validates_format_of     :email,
                          :with       => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i,
                          :message    => 'email must be valid'
  def fullname
    name = first_name + " " + last_name
  end
  
end
