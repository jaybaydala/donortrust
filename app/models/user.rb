require 'digest/sha1'
require 'acts_as_paranoid_versioned'
class User < ActiveRecord::Base

  extend HasAdministrables
  #acts_as_versioned
  acts_as_paranoid_versioned
  has_many :invitations
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :group_news
  #FIXME This association bugs active scaffolding. Probably because there's no group_wall model.
  #has_many :group_walls
  has_many :user_transactions
  has_many :deposits
  has_many :investments
  has_many :gifts
  has_many :pledges
  has_many :pledge_accounts
  has_many :tax_receipts
  has_many :my_wishlists
  has_many :projects, :through => :my_wishlists
  has_many :roles, :through => :administrations
  has_many :administrations
  has_many :orders
  has_many :subscriptions
  has_many :teams, :through => :participants
  has_many :participants
  has_one :profile
  has_administrables :model => "Project"
  has_administrables :model => "Partner"
  has_attached_file :picture, 
                    :styles => { :tiny => "24x24#",:thumb => "48x48#", :normal=>"72x72#" }, 
                    :default_style => :normal,
                    :url => "/images/uploaded_pictures/:attachment/:id/:style/:filename",
                    :default_url => "/images/dt/icons/users/:style/missing.png"

  IMAGE_SIZES = {
    :large => {:width => 500, :height => 500, :modifier => ">"},
    :normal => {:width => 72, :height => 72, :modifier => "#"},
    :thumb => {:width => 48, :height => 48, :modifier => "#"},
    :tiny => {:width => 24, :height => 24, :modifier => "#"}
  }
  has_attached_file :image, :styles => Hash[ *IMAGE_SIZES.collect{|k,v| [k, "#{v[:width]}x#{v[:height]}#{v[:modifier]}"] }.flatten ], 
    :whiny_thumbnails => true,
    :default_style => :normal,
    :convert_options => { 
      :all => "-strip" # strips metadata from images, removing potentially private info
    },
    :default_url => "/images/dt/icons/users/:style/missing.png",
    :storage => :s3,
    :bucket => "uend-images-#{Rails.env}",
    :path => ":class/:attachment/:id/:basename-:style.:extension",
    :s3_credentials => File.join(Rails.root, "config", "aws.yml")
  validates_attachment_size :image, :less_than => 10.megabyte
  validates_attachment_content_type :image, :content_type => %w(image/jpeg image/gif image/png image/pjpeg image/x-png) # the last 2 for IE


  # Virtual attribute for the unencrypted password"
  attr_accessor :password
  attr_accessor :terms_of_use

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  # validates_acceptance_of   :terms_of_use, :on => :create
  validates_presence_of     :terms_of_use, :on => :create, :message => 'must be accepted'
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address"
  validates_uniqueness_of   :activation_code, :allow_nil => :true
  #MP Dec. 14, 2007 - Added to support the US tax receipt functionality
  #Going forward, it would be good to ensure that users have a country.
  validates_presence_of :country, :on => :create, :unless => :under_thirteen?
  validates_presence_of     :display_name

  before_save :encrypt_password
  before_create :make_activation_code
  before_update :login_change

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #def self.authenticate(login, password, check_activated = true)
  #  #u = find_by_login(login) # need to get the salt
  #  u = find_by_login(login, :conditions => ["(last_logged_in_at IS NULL OR last_logged_in_at >= ?)", Time.now.last_year ]) # need to get the salt
  #  #check for account activation using activated_at
  #  #u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
  #
  #  authenticated = u && u.activated? && u.authenticated?(password) ? u : nil if check_activated
  #  authenticated = u && u.authenticated?(password) ? u : nil if !check_activated
  #  u.update_attributes( :last_logged_in_at => Time.now ) if check_activated && authenticated
  #  authenticated
  #end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    # u && u.authenticated?(password) && u.expired? == false ? u : nil
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def name
    return "#{self.first_name} #{self.last_name[0,1]}." if self.display_name.blank?
    self.display_name
  end

   def fullname_login
    "#{self.first_name} #{self.last_name}          (#{self.login})"
  end

  def full_name
   if under_thirteen? || self.first_name.blank?
     self.display_name
   elsif self.last_name.blank?
     self.first_name
   else
     "#{self.first_name} #{self.last_name}"
   end
  end

  def self.find_by_full_name(full_name)
    User.find(:all).each do |user|
      if (user.full_name == full_name)
        return user
      end
    end
    return nil;
  end

  def partner
    contact.partner
  end

  #MP Dec 14, 2007 - Added to support the need to determine whether the user is in a
  #specified country. This supports the US tax receipt functionality
  #If the user's country is nil, or the specified country is nil, or the
  #user's country doesn't match the specified country, this method returns
  #false. Otherwise, it returns true.
  def in_country?(country)
    if self.country.nil? || country.nil? ||
      (self.country.downcase != country.downcase)
          return false
    else
      return true
    end
  end

  def balance
    @balance ||= calculate_balance
  end

  def deposited
    @deposited ||= deposits.inject(0){|sum, d| sum += d.amount}
  end

  def invested
    @invested ||= investments.inject(0){|sum, i| sum += i.amount}
  end

  def gifted(exclude_credit_card = false)
    if (exclude_credit_card)
      @gifted_without_credit_card ||= gifts.find(:all, :conditions => {:credit_card => nil}).inject(0){|sum, g| sum += g.amount}
    else
      @gifted_including_credit_card ||= gifts.inject(0){|sum, g| sum += g.amount}
    end
  end

  def ordered_with_account_balance
    @ordered ||= orders.find_all_by_complete(true, :conditions => "account_balance_payment IS NOT NULL").inject(0){|sum, o| sum += o.account_balance_payment}
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def expired?
    return false if self.last_logged_in_at == nil
    self.last_logged_in_at.to_i < Time.now.last_year.to_i
  end

  def expiry_date
    @expiry_date ||= last_logged_in_at + 1.year
  end

  def expiry_in_days
    ((expiry_date - Time.now) / (3600*24)).floor
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def email
    self.login
  end
  
  def full_email_address
    "\"#{name}\" <#{email}>"
  end

  # Activates the user in the database.
  def activate
    @activated = true
    @activated = update_attributes(:activated_at => Time.now.utc, :activation_code => nil) ? true : false
    @activated
  end

  def cf_admin?
    self.roles.include?(Role.find_by_title('cf_admin'))
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def login_changed?
    @login_changed
  end

  # Returns true if the user has been activated.
  def activated?
    return activation_code ? false : true
  end

  def group_admin?
    @group_admin ||= ( memberships.find(:first, :conditions => ['membership_type >= ?', Membership.admin]) ? true : false)
  end

  def self.find_old_accounts
    User.find(:all, :conditions => ["last_logged_in_at IS NOT NULL AND last_logged_in_at <= ?", 6.months.ago])
  end

  def send_account_reminder
    DonortrustMailer.deliver_account_expiry_reminder(self)
  end

  def is_cf_admin?
    return self.roles.include?(Role.find_by_title('cf_admin'))
  end

  # class method to avoid nil object check
  def self.is_user_cf_admin?(user)
    return Role.find_by_title('cf_admin').users.include?(user)
  end

  # DEPRECATED
  #def is_bus_admin?
  #  self.user_roles.each do |role|
  #    if role.role_type == "busAdmin"
  #      return true
  #    end
  #  end
  #  return false
  #end

  def campaigns
    @campaigns = Campaign.find_by_sql([
      "SELECT c.* from campaigns c INNER JOIN teams t INNER JOIN participants p " +
      "ON c.id = t.campaign_id AND t.id = p.team_id "+
      "WHERE p.user_id = ? ORDER BY c.event_date DESC", self.id])
  end

  def participation
    @participation = Participant.find_by_sql(["SELECT p.* from participants p WHERE p.user_id = ?", self.id])
  end
  
  def find_participant_in_campaign(campaign)
    Participant.find(:first, 
                     :conditions => {:user_id => self.id, 
                                     :team_id => campaign.teams.collect(&:id), 
                                     :active => true})
  end
  
  def can_join_team?(team_to_join)
    # Avoid rejoining current team
    return false if team_to_join.has_user?(self)
    # Cannot join this team if they are active in another team in this campaign
    active_team_participant = Participant.find(:first, 
                                               :conditions => {:user_id => self.id, 
                                                               :team_id => team_to_join.campaign.teams.collect(&:id), 
                                                               :active => true})
    return false if active_team_participant and active_team_participant.team != team_to_join.campaign.default_team
    # Campaign creators cannot move teams
    return false if team_to_join.campaign.owned?(self)
    # Cannot move around unless funds are still being raised
    return false if team_to_join.campaign.start_date > Time.now.utc or team_to_join.campaign.raise_funds_till_date < Time.now.utc
    
    return true
  end
  
  # Attempt to join the default team, returns true if they end up in that team
  def move_to_default_team_in(campaign)
    default_team = campaign.default_team
    
    # Deactivate user from active teams in this campaign
    active_participants = Participant.find(:all, 
                                           :conditions => {:user_id => self.id, 
                                                           :team_id => campaign.teams.collect(&:id), 
                                                           :active => true})
    active_participants.each {|p| p.update_attribute(:active, false)}
    
    # Find or create the default participant in this campaign
    default_participant = Participant.find(:first, :conditions => {:user_id => self.id,
                                                                   :team_id => default_team.id})
    default_participant ||= Participant.new :user_id => self.id,
                                            :team_id => default_team.id,
                                            :pending => false,
                                            :short_name => active_participants.first.short_name,
                                            :about_participant => active_participants.first.about_participant
    default_participant.active = true
    default_participant.save
  end

  def profile
    @profile ||= Profile.find_or_create_by_user_id self.id
    return @profile
  end

  protected
    def validate
      if under_thirteen?
        errors.add("first_name", "cannot be included") unless first_name.blank?
        errors.add("last_name", "cannot be included") unless last_name.blank?
        errors.add("address", "cannot be included") unless address.blank?
        errors.add("city", "cannot be included") unless city.blank?
        errors.add("province", "cannot be included") unless province.blank?
        errors.add("postal_code", "cannot be included") unless postal_code.blank?
        errors.add("country", "cannot be included") unless country.blank?
      end
    end

    def calculate_balance
      balance = deposited  #all deposits
      balance -= ordered_with_account_balance #everything paid for using account balance since introduction of the cart
      balance -= investments.find(:all, :conditions => {:order_id => nil}).inject(0){|sum, i| sum += i.amount} #all investments before the cart
      balance -= gifts.find(:all, :conditions => {:order_id => nil, :credit_card => nil}).inject(0){|sum, i| sum += i.amount}  #all gifts before the cart that were paid for using account balance
      balance || 0
    end

    def self.total_users_in_group
      total = 0
      users = self.find_by_sql("select * from users where id in (select user_id from memberships)")
      total = users.size
    end

    # before filter
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end

    def password_required?
      crypted_password.blank? || !password.blank?
    end

    def make_activation_code
      code = User.generate_activation_code
      # ensure it's not currently being used
      if !User.find_by_activation_code(code)
        self.activation_code = code and return
      end
      # if we get here, it's being used, so try again
      make_activation_code
    end

    def self.generate_activation_code
      hash = ""
      srand()
      (1..12).each do
        rnd = (rand(2147483648)%36) # using 2 ** 31
        rnd = rnd<26 ? rnd+97 : rnd+22
        hash = hash + rnd.chr
      end
      hash
    end

    def self.generate_password
      hash = ""
      srand()
      (1..6).each do
        rnd = (rand(2147483648)%36) # using 2 ** 31
        rnd = rnd<26 ? rnd+97 : rnd+22
        hash = hash + rnd.chr
      end
      hash
    end

    def login_change
      if User.find_by_id(id).login != login
        @login_changed = true
        make_activation_code
      end
    end

end
