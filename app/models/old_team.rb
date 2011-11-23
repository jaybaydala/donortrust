class OldTeam < ActiveRecord::Base
  # after_save :make_uploads_world_readable
  # associations
  belongs_to :old_campaign
  belongs_to :leader, :class_name => "User", :foreign_key => "user_id"
  belongs_to :user

  has_many :old_participants
  has_many :users, :through => :participants

  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy

  has_many :pledges
  has_one :pledge_account

  attr_accessor :use_user_email

  # is_indexed :fields=> [
  #     {:field => 'short_name', :sortable => true},
  #     {:field => 'description'},
  #     {:field => 'name', :sortable => true}
  #   ], 
  #   :delta => true, 
  #   :conditions => "teams.generic=0 AND teams.pending=0"


  # validations
  validates_presence_of :old_campaign
  validates_presence_of :contact_email
  validates_presence_of :name
  validates_presence_of :short_name
  validates_presence_of :description
  validates_presence_of :goal
  validates_presence_of :leader
  validates_numericality_of :goal
  validates_uniqueness_of :user_id, :scope => :campaign_id, :message => "You have already created a team for this campaign and cannot create another one."

  IMAGE_SIZES = {
    :full => {:width => 200, :height => 200, :modifier => ">"},
    :thumb => {:width => 100, :height => 100, :modifier => ">"}
  }
  has_attached_file :image, :styles => Hash[ *IMAGE_SIZES.collect{|k,v| [k, "#{v[:width]}x#{v[:height]}#{v[:modifier]}"] }.flatten ], 
    :default_style => :normal,
    :whiny_thumbnails => true,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :default_url => "/images/dt/icons/users/#{:style}/missing.png",
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  validates_attachment_size :image, :less_than => 1.megabyte,  :unless => Proc.new {|model| model.image }
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png),  :unless => Proc.new {|model| model.image } # the last 2 for IE


  validates_format_of :short_name, :with => /\w/
  validates_length_of :short_name, :within => 4...60
  validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => '^Short name can only contain letters, numbers, and underscores.'


  def validate
    campaign = self.campaign
    if campaign && campaign.allow_multiple_teams?
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

    #add up all the team pledges
    for pledge in self.pledges
      if pledge.paid
        total = total + pledge.amount
      end
    end

    #add in all the pledges to team members
    self.participants.each do |p|
      p.pledges.each do |pledge|
        if pledge.paid
      	  total = total + pledge.amount
      	end
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
  
  def active_and_current_participants
    Participant.find(:all, :conditions => {:team_id => self.id, :pending => false, :active => true})
  end

  def participant_for_user(user)
    if !user
      return nil
    end
    # Find the team that this user is actively participating in
    participants.find(:first, :conditions => {:user_id => user.id, :active => true})
  end

  #############TODO##############
  def campaign_over?

  end

  def has_user?(user)
    if !user
      return false
    end
    participant = participants.find(:first, :conditions => {:user_id => user.id, :active => true})
    return (participant && participant.user)
  end

  def joinable?
    if not campaign.valid?
      return false;
    end

    (!self.pending && !self.is_full?)? true : false
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
  # def make_uploads_world_readable
  #   return if picture.nil?
  #   list = self.picture.versions.map {|version, image| image.path }
  #   list << self.picture.path
  #   FileUtils.chmod_R(0644, list) unless list.empty?
  # end
end
