require 'digest/sha1'
require 'acts_as_paranoid_versioned' 
class User < ActiveRecord::Base
  #acts_as_versioned
  acts_as_paranoid_versioned
  has_many :invitations
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :user_transactions
  has_many :deposits
  has_many :investments
  has_many :gifts
  has_many :tax_receipts
  has_many :my_wishlists
  has_many :projects, :through => :my_wishlists

  # Virtual attribute for the unencrypted password
  attr_accessor :password
  attr_accessor :terms_of_use

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_acceptance_of   :terms_of_use, :on => :create
  validates_presence_of     :terms_of_use, :on => :create, :message => 'must be accepted'
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address"
  validates_uniqueness_of   :activation_code, :allow_nil => :true
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
    u && u.authenticated?(password) && u.expired? == false ? u : nil
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
    under_thirteen? ? self.display_name : "#{self.first_name} #{self.last_name}" 
  end

  def balance
    @balance ||= calculate_balance
  end

  def deposited
    @deposited ||= calculate_deposits
  end

  def invested
    @invested ||= calculate_investments
  end

  def gifted(exclude_credit_card = false)
    if (exclude_credit_card)
      @gifted_without_credit_card ||= calculate_gifts(exclude_credit_card)
    else
      @gifted_with_credit_card ||= calculate_gifts(exclude_credit_card)
    end
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

  # Activates the user in the database.
  def activate
    @activated = true
    update_attributes(:activated_at => Time.now.utc, :activation_code => nil)
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
      else
        errors.add("first_name", "cannot be blank if Display name is empty") if first_name.blank? && display_name.blank?
        errors.add("last_name", "cannot be blank if Display name is empty") if last_name.blank? && display_name.blank?
        errors.add("display_name", "cannot be blank if First Name and Last Name are empty") if display_name.blank? && first_name.blank? && last_name.blank?
      end
    end
        
    def calculate_balance
      balance = deposited - invested - gifted(true) || 0
    end

    def calculate_deposits
      deposits = Deposit.find(:all, :conditions => { :user_id => self[:id] })
      balance = 0
      deposits.each do |trans|
        balance = balance + trans.amount
      end
      balance
    end

    def calculate_investments
      investments = Investment.find(:all, :conditions => { :user_id => self[:id] })
      balance = 0
      investments.each do |trans|
        balance = balance + trans.amount
      end
      balance
    end

    def calculate_gifts(exclude_credit_card = false)
      conditions = { :user_id => self[:id] }
      conditions[:credit_card] = nil if exclude_credit_card == true
      gifts = Gift.find(:all, :conditions => conditions)
      balance = 0
      gifts.each do |trans|
        balance = balance + trans.amount
      end
      balance
    end
    
    def self.total_users_in_group
      total = 0
      users = self.find_by_sql("Select * from users where id in (select user_id from memberships)")
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
