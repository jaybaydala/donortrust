class Team < ActiveRecord::Base
  # associations
  belongs_to :campaign
  belongs_to :leader, :class_name => "User", :foreign_key => "user_id"

  has_many :participants
  has_many :users, :through => :participants

  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy

  attr_accessor :use_user_email

  # validations
  validates_presence_of :contact_email

  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "team_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/team_pictures"

  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true


 def validate
   campaign = self.campaign
   if(campaign.allow_multiple_teams?)
     errors.add_to_base "The maximum number of teams (#{campaign.max_number_of_teams}) has been reached for this campaign." unless not campaign.teams_full?
     errors.add 'short_name', " has already been used in this campaign." unless Team.find_by_campaign_id_and_short_name(campaign, self.short_name) == nil
   end
 end

  def before_validation_on_create
    if use_user_email == "1"
      self.contact_email = current_user.email
    end
  end

  def goal_with_currency
    self.goal_currency ||= 'CDN'
    return "#{self.goal} $#{self.goal_currency}"
  end

  def funds_raised
    total = 0
    for participant in self.participants
      total = total + participant.funds_raised
    end
    total
  end

  def activate!
    self.update_attribute(:pending,false) ? true : false;
  end

  #check if the current user is the owner of this team
  def owned?
    current_user != nil ? self.leader == current_user : false;
  end

  def is_full?
    self.campaign.max_size_of_teams ? (self.participants.size >= self.campaign.max_size_of_teams): false
  end

  def joinable?
    (!self.pending && !self.is_full? && !self.campaign.has_participant(current_user))? true : false
  end

end
