class Account < ActiveRecord::Base
  
  def fullname
    name = first_name + " " + last_name
  end
end
