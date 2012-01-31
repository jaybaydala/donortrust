class Profile < ActiveRecord::Base
  
  belongs_to :user
  
  validates_presence_of :user
  
  def decrease_gifts
    update_attribute(:non_uend_gifts, non_uend_gifts - 1) if (self.non_uend_gifts > 0)
  end
  
  def increase_gifts
    update_attribute(:non_uend_gifts, non_uend_gifts + 1)
  end
  
  # Methods to calculate statistics
  def statistics
    return [gifts_given, gifts_received, external_gifts, people_impacted,
            campaigns_completed, raised_towards_projects, people_told, gifts_refocused]
  end
  
  def gifts_given
    # Basically count all gifts with this user's id
    @gifts_given ||= Gift.count(:all, :conditions => {:user_id => self.user_id})
    return [@gifts_given, "gifts given"]
  end
  
  def gifts_received
    # Match this user's email with the recipient of the gifts e-mail
    @gifts_received ||= Gift.count(:all, :conditions => {:to_email => user.login})
    return [@gifts_received, "gifts received"]
  end
  
  def external_gifts
    # This value is updated by the user
    return [non_uend_gifts, "non-UEnd gifts"]
  end
  
  def friends_people_impacted
    result = user.friends.inject(0) { |i, f| 
      i + f.profile.people_impacted.first
    }
    return [result, "people impacted"]
  end

  def people_impacted
    # This is calulated by taking the proportion contributed to each project
    # by this user against the overall project need to determine the number
    # of lives affected and totaling this amount for all projects
    result = 0
    investments_by_project = user.investments.group_by(&:project_id)
    investments_by_project.each do |project_id, investments|
      project = Project.find project_id
      if project.lives_affected?
        project_investment = investments.sum{|i| i.amount}
        result += (project_investment * project.lives_affected / project.total_cost).floor.to_i
      end
    end
    return [result, "people impacted"]
  end
  
  def campaigns_completed
    # Campaign is considered complete if funds can no longer be raised
    campaigns_completed = user.campaigns.select{|c| c.raise_funds_till_date < Time.now}.size
    return [campaigns_completed, "campaigns completed"]
  end
  
  def raised_towards_projects
    # Sum the amounts for all this user's investments assigned to any project
    raised_towards_projects = Investment.sum(:all,  :select => "amount",
                                             :conditions => ["user_id = ? AND project_id IS NOT NULL", self.user_id])
    return [number_to_currency(raised_towards_projects), "towards projects"]
  end
  
  def people_told
    return [Invitation.count(:conditions => {:user_id => self.user_id}), "people told"]
  end
  
  def gifts_refocused
    # This is the proportion of gifts given through UEnd to all gifts incl. traditional gifts
    return ["0 %", "My Gifts Refocused"] if non_uend_gifts == 0
    self.gifts_given    # in case instance variable isn't populated
    self.gifts_received # in case instance variable isn't populated
    total_gifts = @gifts_given.to_f + @gifts_received.to_f
    gifts_refocused = (100.to_f * total_gifts / (non_uend_gifts.to_f + total_gifts)).floor
    return ["#{gifts_refocused} %", "My Gifts Refocused"]
  end
  # end of statistics methods
end
