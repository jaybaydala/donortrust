class Campaign < ActiveRecord::Base
  after_save :make_uploads_world_readable
  belongs_to :campaign_type
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id'

  # wall posts
  has_many :wall_posts, :as =>:postable, :dependent => :destroy

  # news items
  has_many :news_items, :as =>:postable, :dependent => :destroy

  has_many :teams, :dependent => :destroy
  has_many :participants, :through => :teams

  has_and_belongs_to_many :projects

  has_many :place_limits
  has_many :places, :through => :place_limits

  has_many :cause_limits
  has_many :causes, :through => :cause_limits

  has_many :partner_limits
  has_many :partners, :through => :partner_limits

  has_many :pledges
  has_many :investments

  has_one :default_team, :dependent => :destroy, :class_name => "Team"

  attr_accessor :use_user_email

  is_indexed :fields=> [
      {:field => 'name', :sortable => true},
      {:field => 'description'},
      {:field => 'city'},
      {:field => 'province'},
      {:field => 'country'}
    ], 
    :delta => true, 
    :include => [
          {:class_name => 'Team',
            :field => 'teams.name',
            :as => 'team_name',
            :association_sql => "LEFT JOIN (teams) ON (teams.campaign_id=campaigns.id)"
           },
           {
             :class_name=> 'Team',
             :field => 'teams1.short_name',
             :as => 'team_short_name',
             :association_sql => "LEFT JOIN (teams as teams1) ON (teams1.campaign_id=campaigns.id)"
           },
           {
             :class_name => 'Team',
             :field => 'teams2.description',
             :as => 'team_description',
             :association_sql => "LEFT JOIN (teams as teams2) ON (teams2.campaign_id=campaigns.id)"
           }
          ]

  #validations
  validates_presence_of :name, :campaign_type, :description, :country, :province, :postalcode, :fundraising_goal, :creator, :short_name

  validates_uniqueness_of :short_name, :message => "the short name is not unique"
  validates_format_of :short_name, :with => /\w/, :message => "the short name must start with an alphabetic character (a-z)"
  validates_length_of :short_name, :within => 4...60
  validates_format_of :short_name, :with => /^[a-zA-Z0-9_]+$/, :message => "Short name can only contain letters, numbers, and underscores."

  validates_length_of :name, :within => 4..255
  validates_length_of :description, :minimum => 10

  validates_numericality_of :fundraising_goal, :fee_amount, :greater_than_or_equal_to => 0, :allow_nil => true
  validates_numericality_of :max_number_of_teams, :max_size_of_teams, :max_participants, :fee_amount, :greater_than_or_equal_to => 0, :only_integer => true, :allow_nil => true

  #Deal with postal code in terms of Canada
  validates_format_of :postalcode, :with => /(\D\d){3}/, :if => :in_canada? , :message => "In Canada the proper format for postal code is: A9A9A9, Where A is a leter between A-Z and 9 is a number between 0 - 9."
  validates_length_of :postalcode, :is => 6, :if => :in_canada?

  #Deal with Zip code in terms of USA
  validates_numericality_of :postalcode, :if => :in_usa?, :message => "Zip codes must be a number."
  validates_length_of :postalcode, :is => 5, :if => :in_usa?

  image_column  :picture,
                :versions => { :thumb => "75x75", :full => "150x150"  },
                :filename => proc{|inst, orig, ext| "campaign_#{inst.id}.#{ext}"},
                :store_dir => "uploaded_pictures/campaign_pictures"
  validates_size_of :picture, :maximum => 500000, :message => "might be too big, must be smaller than 500kB!", :allow_nil => true


  def before_validation
    if use_user_email == "1"
      self.email = current_user.email
    end

    #hard coding currency
    self.fee_currency = "CDN"
    self.goal_currency = "CDN"

    #self.pending = true

    self.postalcode = postalcode.sub(' ', '') if not postalcode.blank? # remove any spaces.
  end

  def valid?
    if errors.count > 0
      puts "Errors: " + errors.full_messages.to_s
    end

    return super
  end

  def validate
    errors.add('start_date',"must be before the event date.")if start_date > event_date
    errors.add('start_date',"must be before the \"Raise Funds Till\" date.")if start_date > raise_funds_till_date
    errors.add('allocate_funds_by_date',"must be after the \"Raise Funds Till\" date.")if allocate_funds_by_date < raise_funds_till_date
    errors.add('email',"Must provide an email to use for contact." ) if email == ""

    if in_canada?
      errors.add('postalcode',"Is not correct for your province") if not postalcode_matches_province?
    end

    if in_usa?
      errors.add('postalcode',"Is not correct for your state") if not zipcode_matches_state?
    end

  end

  def has_project?(project)
    projects.each do |p|
      if project == p
        return true
      end
    end

    return false
  end

  def after_save
    if not self.allow_multiple_teams? # if only one team is allowed build the container team.
      Team.create :name => self.name, :short_name => self.short_name, :description => self.description, :campaign_id => self.id, :contact_email => self.email, :user_id => self.user_id, :pending => 0
    end
  end

  def funds_raised
    total = 0;
    for pledge in self.pledges
      if pledge.paid
        total = total + pledge.amount
      end
    end

    self.teams.each do |t|
      total = total + t.funds_raised
    end

    total
  end

  def eligible_projects
    Project.find_by_sql("SELECT p.* FROM projects p, causes_limit JOIN causes_limit ON ")
  end

  def teams_full?
    return (self.teams.size >= self.max_number_of_teams if self.max_number_of_teams?)
  end

  def percentage_done
    raised= ((self.funds_raised.to_f/self.fundraising_goal.to_f)*100).round(0).to_i
    "#{raised} %"
  end

  def manage_link
    (link_to('Manage Campaign',manage_dt_campaign_path(self)) + " | ") unless not self.owned?
  end

  def fundraising_goal_with_currency
    "#{self.fundraising_goal} #{self.goal_currency}"
  end

  def campaign_fee_with_currency
    "#{self.fee_amount} #{self.fee_currency}"
  end

  def is_active?
    self.active == true
  end

  def in_canada?
    country == 'Canada'
  end

  def in_usa?
    country == 'United States'
  end

  #check if the current user is the owner of this campaign
  def owned?
    current_user != nil ? self.creator == current_user : false;
  end

  def activate!
    self.update_attribute(:pending, false)
  end

  def pending_teams
    Team.find_all_by_campaign_id_and_pending(self.id, true)
  end

  def active_teams
    Team.find_all_by_campaign_id_and_pending(self.id, false)
  end

  def can_join_team?(user)
    #if the user is on the default team then we can still join another team
    if (self.default_team.users.include?(user)) then
      puts "user is on default team"
      return false
    end

    #see if the user is on another team
    if (participants.include?(user)) then
      puts "user is on another team"
      return false
    end

    return true
  end

  def participating?(user)
    participants.include?(user)
  end

  def not_pending_participants
    @participants = Participant.find_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = 0",self.id])
  end
  
  def pending_participants
    @participants = Participant.find_by_sql(["SELECT p.* FROM participants p, teams t WHERE p.team_id = t.id AND t.campaign_id = ? AND p.pending = 1",self.id])
  end

  def has_participant(user)
    users = User.find_by_sql(["SELECT u.* FROM users u, teams t, participants p WHERE p.user_id = u.id AND p.team_id = t.id AND t.campaign_id = ? AND u.id = ?",self.id, user])
    users.first ? true : false;
  end

  def generic_team
    Team.find_by_campaign_id_and_generic(self.id, true)
  end

  private
    # check that the postalcode follows the canadian standard for postal codes, see http://en.wikipedia.org/wiki/Canadian_postal_code
    def postalcode_matches_province?
      provinceHash = Hash.new
      provinceHash['NL'] = /A/i
      provinceHash['NS'] = /B/i
      provinceHash['PE'] = /C/i
      provinceHash['NB'] = /E/i
      provinceHash['QC'] = /G|H|J/i
      provinceHash['ON'] = /K|L|M|N|O|P/i
      provinceHash['MB'] = /R/i
      provinceHash['SK'] = /S/i
      provinceHash['AB'] = /T/i
      provinceHash['BC'] = /V/i
      provinceHash['NT'] = /X/i
      provinceHash['NU'] = /X/i
      provinceHash['YT'] = /Y/i
      (provinceHash[province] =~ postalcode) == 0
    end

    #check that the zip code follows the american standard, see http://en.wikipedia.org/wiki/Zip_code
    def zipcode_matches_state?
      zipArray = Array.new
      zipArray[0] = /CT|MA|ME|NH|NJ|RI|VT/
      zipArray[1] = /DE|NY|PA/
      zipArray[2] = /DC|MD|NC|SC|VA|WV/
      zipArray[3] = /AL|FL|GA|MS|TN/
      zipArray[4] = /IN|KY|MI|OH/
      zipArray[5] = /IA|MN|MT|ND|SD|WI/
      zipArray[6] = /IL|KY|MO|NE/
      zipArray[7] = /AR|LA|OK|TX/
      zipArray[8] = /AZ|CO|ID|NM|NV|UT|WY/
      zipArray[9] = /AK|CA|HI|OR|WA/
      (zipArray[postalcode.chars.first.to_i] =~ province) != nil
    end

    def make_uploads_world_readable
      return if picture.nil?
      list = self.picture.versions.map {|version, image| image.path }
      list << self.picture.path
      FileUtils.chmod_R(0644, list) unless list.empty?
    end
end
