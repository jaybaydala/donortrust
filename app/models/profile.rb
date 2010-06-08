class Profile < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :user
  
  # Methods to calculate statistics
  def statistics
    return [gifts_given, gifts_received, non_uend_gifts, people_impacted,
            campaigns_completed, raised_towards_projects, people_told, gifts_refocused]
  end
  
  def gifts_given
    # Basically count all gifts with this user's id
    @gifts_given ||= Gift.count(:all, :conditions => {:user_id => self.user_id})
    return [@gifts_given, "gifts given"]
  end
  
  def gifts_received
    # Match this user's email with the recipient of the gifts e-mail
    return [Gift.count(:all, :conditions => {:to_email => user.login}), "gifts received"]
  end
  
  def non_uend_gifts
    # TODO: This is a placeholder
    @non_uend_gifts ||= 1614
    return [@non_uend_gifts, "non-UEnd gifts"]
  end
  
  def people_impacted
    # TODO: This is a placeholder
    return ["11,195", "people impacted"]
  end
  
  def campaigns_completed
    # Campaign is considered complete if funds can no longer be raised
    campaigns_completed = user.campaigns.select{|c| c.raise_funds_till_date < Time.now}.size
    return [campaigns_completed, "campaigns completed"]
  end
  
  def raised_towards_projects
    # Sum the amounts for all this user's investments assigned to any project
    raised_towards_projects = Investment.sum(:all, :conditions => ["user_id = ? AND project_id IS NOT NULL", self.user_id], :select => "amount")
    return ["$ #{raised_towards_projects}", "towards projects"]
  end
  
  def people_told
    return [Invitation.count(:conditions => {:user_id => self.user_id}), "people told"]
  end
  
  def gifts_refocused
    # This appears to be the proportion of gifts given to traditional gifts
    self.gifts_given # in case instance variable isn't populated
    self.non_uend_gifts # in case instance variable isn't populated
    gifts_refocused = (100.to_f * @gifts_given.to_f / @non_uend_gifts.to_f).floor
    return ["#{gifts_refocused} %", "My Gifts Refocused"]
  end
  # end of statistics methods
end