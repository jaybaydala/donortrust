class Campaign < ActiveRecord::Base
  belongs_to :campaign_type
  belongs_to :creator, :class_name => 'User', :foreign_key => 'user_id'
  
  # wall posts
  has_many :wall_posts, :as =>:postable, :dependent => :destroy
  
  # news items
  has_many :news_items, :as =>:postable, :dependent => :destroy
  
  has_many :teams
  
  has_many :project_limits
  has_many :projects, :through => :project_limits
  
  has_many :place_limits
  has_many :places, :through => :place_limits
  
  has_many :cause_limits
  has_many :causes, :through => :cause_limits
  
  has_many :partner_limits
  has_many :partners, :through => :partner_limits  
    
  attr_accessor :use_user_email
  
  
  #validations
  validates_presence_of :name, :campaign_type, :description, :country, :province, :postalcode, :fundraising_goal, :creator, :short_name
  
  validates_uniqueness_of :short_name
  validates_format_of :short_name, :with => /\w/
  validates_length_of :short_name, :within => 4...60
  
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
  
  def before_validation
    if use_user_email == "1"
      self.email = current_user.email
    end
  
    #hard coding currency  
    self.fee_currency = "$ CDN"
    self.goal_currency = "$ CDN"
  
    self.pending = true
  
    self.postalcode = postalcode.sub(' ', '') if not postalcode.blank?# remove any spaces.  
  end

  
  def validate
    errors.add('start_date',"must be less than end date")if start_date > end_date
    errors.add('email',"Must provide an email to use for contact." ) if email == ""
    
    if in_canada?
      errors.add('postalcode',"Is not correct for your province") if not postalcode_matches_province?
    end
    
    if in_usa?
      errors.add('postalcode',"Is not correct for your state") if not zipcode_matches_state?
    end
  
  end
  
  def eligible_projects
    Project.find_by_sql("SELECT p.* FROM projects p, causes_limit JOIN causes_limit ON ")
  end
  
  def teams_full?
    return self.teams.size == self.max_number_of_teams and self.max_number_of_teams != 0
  end
  
  def manage_link
    (link_to('Manage Campaign',manage_dt_campaign_path(self)) + " | ") unless not self.owned?
  end
  
  def fundraising_goal_with_currency
    "#{self.fundraising_goal} #{self.goal_currency}"
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
    self.update_attribute(:pending,false) ? true : false;
  end
  
  
  def pending_teams
    Team.find_all_by_campaign_id_and_pending(self.id, true)
  end
  
  def active_teams
    Team.find_all_by_campaign_id_and_pending(self.id, false)
  end
  
  def participants
    User.find_by_sql(["SELECT u.* FROM users u, teams t, team_members tm WHERE tm.user_id = u.id AND tm.team_id = t.id AND t.campaign_id = ?",self.id])
  end
  
  private
  # check that the postalcode follows the canadian standard for postal codes, see http://en.wikipedia.org/wiki/Canadian_postal_code
  def postalcode_matches_province?
    provinceHash = Hash.new
    provinceHash['Newfoundland']          = /A/i
    provinceHash['Nova Scotia']           = /B/i
    provinceHash['Prince Edward Islant']  = /C/i
    provinceHash['New Brunswick']         = /E/i
    provinceHash['Quebec']                = /G|H|J/i
    provinceHash['Ontario']               = /K|L|M|N|O|P/i
    provinceHash['Manitoba']              = /R/i
    provinceHash['Saskatchewan']          = /S/i
    provinceHash['Alberta']               = /T/i
    provinceHash['British Columbia']      = /V/i
    provinceHash['Northwest Territories'] = /X/i
    provinceHash['Nunavut']               = /X/i
    provinceHash['Yukon']                 = /Y/i
    (provinceHash[province] =~ postalcode) == 0
  end
  
  #check that the zip code follows the american standard, see http://en.wikipedia.org/wiki/Zip_code
  def zipcode_matches_state?
    zipArray = Array.new
    zipArray[0] = /Connecticut|Massachusetts|Maine|New Hampshire|New Jersey|Puerto Rico|Rhode Island|Vermont|Virgin Islands|Army Post Office Europe|Fleet Post Office Europe/
    zipArray[1] = /Delaware|New York|Pennsylvania/
    zipArray[2] = /District of Columbia|Maryland|North Carolina|South Carolina|Virginia|West Virginia/
    zipArray[3] = /Alabama|Florida|Georgia|Mississippi|Tennessee|Army Post Office Americas|Fleet Post Office Americas/
    zipArray[4] = /Indiana|Kentucky|Michigan|Ohio/
    zipArray[5] = /Iowa|Minnesota|Montana|North Dakota|South Dakota|Wisconsin/
    zipArray[6] = /Illinois|Kansas|Missouri|Nebraska/
    zipArray[7] = /Arkansas|Louisiana|Oklahoma|Texas/
    zipArray[8] = /Arizona|Colorado|Idaho|New Mexico|Nevada|Utah|Wyoming/
    zipArray[9] = /Alaska|American Samoa|California|Guam|Hawaii|Marshall Islands|Federated States of Micronesia|Northern Mariana Islands|Oregon|Palau|Washington|Army Post Office Pacific|Fleet Post Office Pacific/
    (zipArray[postalcode.chars.first.to_i] =~ province) != nil
  end
  
end
