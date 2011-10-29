class OldParticipant < ActiveRecord::Base
  # after_save :make_uploads_world_readable
  belongs_to :user
  belongs_to :old_team
  belongs_to :old_campaign

  attr_accessor :new_reg_login
  attr_accessor :new_reg_password
  attr_accessor :new_reg_password_confirm
  attr_accessor :new_reg_terms_of_use
  attr_accessor :new_reg_country
  attr_accessor :new_reg_display_name

  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  has_many :news_items, :as =>:postable, :dependent => :destroy

  has_many :pledges
  has_one :registration_fee

  has_many :deposits, :through => :pledges
  # is_indexed :fields=> [
  #   {:field => 'short_name', :sortable => true},
  #   {:field => 'about_participant'}
  #   ], 
  #   :delta => true, 
  #   :include => [
  #     {:association_name => 'user',
  #       :field => 'users.first_name',
  #       :as => 'user_first_name',
  #       :association_sql => "LEFT JOIN (users) ON (participants.user_id=users.id)"
  #       },
  #       {
  #         :association_name => 'user',
  #         :field => 'users1.last_name',
  #         :as => 'user_last_name',
  #         :association_sql => "LEFT JOIN (users as users1) ON (participants.user_id=users1.id)"
  #         },
  #         {
  #           :association_name => 'user',
  #           :field => 'users2.display_name',
  #           :as => 'user_display_name',
  #           :association_sql => "LEFT JOIN (users as users2) ON (participants.user_id=users2.id)"
  #         }
  #   ]


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
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png), :unless => Proc.new {|model| model.image } # the last 2 for IE


  validates_presence_of :user_id, :team_id
  validates_numericality_of :goal, :allow_nil => true
  validates_uniqueness_of :user_id, :scope => :team_id, :message => 'currently logged in is already a member of this team'

  # validates_format_of :short_name, :with => /\w/
  # validates_length_of :short_name, :within => 3...60, :message => 'Short name must be between 3 and 60 characters'
  # validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => '^Short name can only contain letters, numbers, and underscores.'
  
  def approve!
    self.update_attribute(:pending,false) ? true : false;
  end

  def owned?
    current_user != nil ? self.user == current_user : false;
  end

  def name
    self.user.full_name if self.user_id? && self.user
  end

#  def validate
#    campaign = self.campaign
#    if(campaign.allow_multiple_teams?)
#      errors.add_to_base "The maximum number of teams (#{campaign.max_number_of_teams}) has been reached for this campaign." unless not campaign.teams_full?
#      @participant_to_test = Participant.find_by_campaign_id_and_short_name(campaign, self.short_name)
#      errors.add 'short_name', " has already been used in this campaign." unless @team_to_test == nil or @team_to_test == self
#    end
#  end
  
  def funds_raised
    total = 0;
    for pledge in self.pledges
      if pledge.paid
        total = total + pledge.amount
      end
    end
    total
  end

  def short_about_participant(length = 100)
    short_about_participant = (self.about_participant.length > length) ? self.about_participant[0...length] + '...' : self.about_participant
  end

  def percentage_raised
    if self.goal?
      raised= ((self.funds_raised.to_f/self.goal.to_f)*100).round(0).to_i
      "#{raised} %"
    else
      "n/a"
    end
  end

  def campaign
    self.team.campaign if self.team_id? && self.team
  end
  
  def has_paid_registration_fee?
    if not campaign.has_registration_fee?
      return true
    end

    if not registration_fee.nil?
      if registration_fee.paid
        return true
      end
    end

    return false
  end
  
  def can_leave_team?
    # Must be active in a team to leave
    return false unless active
    # Cannot leave a team you created or currently lead
    return false if team.owned? or team.leader == user
    # Cannot leave the default team
    return false if team == campaign.default_team
    # Changing teams only matters while funds are being raised
    return false if (campaign.start_date > Time.now.utc) or (campaign.raise_funds_till_date < Time.now.utc)
    
    return true
  end
  
  def self.create_from_unpaid_participant!(unpaid_participant_id)
    logger.debug "Creating a Participant from an UnpaidParticipant"
    unpaid_participant = UnpaidParticipant.find(unpaid_participant_id)

    logger.debug "UnpaidParticipant: #{unpaid_participant.inspect}"
    
    participant = Participant.new
    [:team_id, :user_id, :short_name, :pending, :private, :about_participant, :goal].each do |attr|
      participant[attr] = unpaid_participant[attr]
    end
    participant.image = File.open(unpaid_participant.image.path, 'r')
    participant.save!
    unpaid_participant.destroy
    logger.debug "Participant created: #{participant.inspect}"
    participant
  end
end
