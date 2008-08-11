class Team < ActiveRecord::Base
  # associations
  belongs_to :campaign
  belongs_to :leader, :class_name => "User", :foreign_key => "user_id"
  has_many :team_members
  has_many :users, :through => :team_members
  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy
  
  attr_accessor :use_user_email, :campaign
  
  # validations
  validates_presence_of :contact_email
  
   def validate
     campaign = self.campaign
     errors.add_to_base "The maximum number of teams (#{campaign.max_number_of_teams}) has been reached for this campaign." unless not campaign.teams_full?
   end
  
  def before_validation
    if use_user_email == "1"
      self.contact_email = current_user.email
    end
  end
  
  def before_save  
    # set to pending if need be
    if self.campaign.require_team_authorization?
      self.pending = true
    else
      self.pending = false
    end
  end
  
  def activate!
    self.update_attribute(:pending,false) ? true : false;
  end
  
  #check if the current user is the owner of this team
  def owned?
    current_user != nil ? self.leader == current_user : false;
  end
end
