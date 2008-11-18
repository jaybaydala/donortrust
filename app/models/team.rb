class Team < ActiveRecord::Base
  after_save :make_uploads_world_readable
  # associations
  belongs_to :campaign
  belongs_to :leader, :class_name => "User", :foreign_key => "user_id"

  has_many :participants, :dependent => :destroy
  has_many :users, :through => :participants

  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy

  has_many :pledges

  attr_accessor :use_user_email

  is_indexed :fields=> [
      {:field => 'short_name', :sortable => true},
      {:field => 'description'},
      {:field => 'name', :sortable => true}
    ], 
    :delta => true, 
    :conditions => "teams.generic=0 AND teams.pending=0"


  # validations
  validates_presence_of :campaign
  validates_presence_of :contact_email
  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :description
  validates_presence_of :goal
  validates_presence_of :leader
  validates_numericality_of :goal

  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "team_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/team_pictures"

  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true

  validates_format_of :short_name, :with => /\w/
  validates_length_of :short_name, :within => 4...60
  validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => '^Short name can only contain letters, numbers, and underscores.'


  def validate
    campaign = self.campaign
    if(campaign.allow_multiple_teams?)
      errors.add_to_base "The maximum number of teams (#{campaign.max_number_of_teams}) has been reached for this campaign." unless not campaign.teams_full?
      @team_to_test = Team.find_by_campaign_id_and_short_name(campaign, self.short_name)
      errors.add 'short_name', " has already been used in this campaign." unless @team_to_test == nil or @team_to_test == self
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
    total = 0;
    for pledge in self.pledges
      if pledge.paid
        total = total + pledge.amount
      end
    end
    total
  end

  def approve!
    self.update_attribute(:pending,false) ? true : false;
  end

  #check if the current user is the owner of this team
  def owned?
    current_user != nil ? self.leader == current_user : false;
  end

  def is_full?
    self.campaign.max_size_of_teams ? (self.participants.size >= self.campaign.max_size_of_teams): false
  end

  def pending_participants
    Participant.find_all_by_team_id_and_pending(self.id, true)
  end

  def active_participants
    Participant.find_all_by_team_id_and_pending(self.id, false)
  end


  #############TODO##############
  def campaign_over?

  end

  def joinable?
    (!self.pending && !self.is_full? && !self.campaign.has_participant(current_user.id))? true : false
  end

  def short_description(length=100)
    return "" if self.description == nil
    short_description = (self.description.length > length) ? self.description[0...length] + '...' : self.description
  end

  def percentage_raised
    if self.goal?
      raised= ((self.funds_raised.to_f/self.goal.to_f)*100).round(0).to_i
      "#{raised} %"
    else
      "n/a"
    end
  end

  private
  def make_uploads_world_readable
    return if picture.nil?
    list = self.picture.versions.map {|version, image| image.path }
    list << self.picture.path
    FileUtils.chmod_R(0644, list) unless list.empty?
  end
end
