class Team < ActiveRecord::Base
  belongs_to :campaign
  has_many :team_members
  
  attr_accessor :use_user_email
  
  def before_validation
    if use_user_email == "1"
      self.email = current_user.email
    end
  end
  
end
