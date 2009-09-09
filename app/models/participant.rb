class Participant < ActiveRecord::Base
  after_save :make_uploads_world_readable
  belongs_to :user
  belongs_to :team
  belongs_to :campaign

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
  is_indexed :fields=> [
    {:field => 'short_name', :sortable => true},
    {:field => 'about_participant'}
    ], 
    :delta => true, 
    :include => [
      {:association_name => 'user',
        :field => 'users.first_name',
        :as => 'user_first_name',
        :association_sql => "LEFT JOIN (users) ON (participants.user_id=users.id)"
        },
        {
          :association_name => 'user',
          :field => 'users1.last_name',
          :as => 'user_last_name',
          :association_sql => "LEFT JOIN (users as users1) ON (participants.user_id=users1.id)"
          },
          {
            :association_name => 'user',
            :field => 'users2.display_name',
            :as => 'user_display_name',
            :association_sql => "LEFT JOIN (users as users2) ON (participants.user_id=users2.id)"
          }
    ]


  image_column  :picture,
                :versions => { :thumb => "100x100", :full => "200x200"  },
                :filename => proc{|inst, orig, ext| "participant_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/participant_pictures"

  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true

  validates_presence_of :user, :team, :campaign
  validates_numericality_of :goal, :allow_nil => true
  validates_uniqueness_of :user_id, :scope => :team_id, :message => 'currently logged in is already a member of this team'

  validates_format_of :short_name, :with => /\w/
  validates_length_of :short_name, :within => 3...60, :message => 'Short name must be between 3 and 60 characters'
  validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => '^Short name can only contain letters, numbers, and underscores.'
  
  def approve!
    self.update_attribute(:pending,false) ? true : false;
  end

  def owned?
    current_user != nil ? self.user == current_user : false;
  end

  def name
    self.user.full_name
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
    self.team.campaign
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
  
  def self.create_from_unpaid_participant!(unpaid_participant_id)
    logger.debug "Creating a Participant from an UnpaidParticipant"
    unpaid_participant = UnpaidParticipant.find(unpaid_participant_id)

    logger.debug "UnpaidParticipant: #{unpaid_participant.inspect}"
    
    participant = Participant.new
    [:team_id, :user_id, :short_name, :pending, :private, :about_participant, :picture, :goal].each do |attr|
      participant[attr] = unpaid_participant[attr]
    end
    participant.save!
    unpaid_participant.destroy
    logger.debug "Participant created: #{participant.inspect}"
    participant
  end
  
  private
  def make_uploads_world_readable
    return if picture.nil?
    list = self.picture.versions.map {|version, image| image.path }
    list << self.picture.path
    FileUtils.chmod_R(0644, list) unless list.empty?
  end
end
