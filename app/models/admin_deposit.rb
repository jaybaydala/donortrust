#MP Dec 14, 2007
#Added this class to support the need for CF admins to create deposits
#on behalf of donors who have made their donation through GroundSpring.org
#The intent of this class is to override the validations and before_save functionality
#of the Deposit class. In this case, we just need to make the entry into the database,
#no validation of the nature found in the base class's validate method is required.
class AdminDeposit < Deposit
  
  def validate
    #override the base class functionality so that we don't get the normal validation
  end
  
  def before_save
    #override the base class functionality so that we don't get the normal before_save behavior
  end
  
end