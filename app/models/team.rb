class Team < ActiveRecord::Base
  belongs_to :campaign
  belongs_to :author, :class_name => "User", :foreign_key => "user_id"
  
  has_many :team_members
  
  # wall posts
  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  
  # news items
  has_many :news_items, :as =>:postable, :dependent => :destroy
  
  attr_accessor :use_user_email
  
  validates_presence_of :contact_email
  
  def before_validation
    if use_user_email == "1"
      self.contact_email = current_user.email
    end
    
    if self.campaign.require_team_authorization
      self.pending = true
    end
  end
end
