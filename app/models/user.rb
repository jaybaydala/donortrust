require 'digest/sha1'
require 'acts_as_paranoid_versioned' 
class User < ActiveRecord::Base
  #acts_as_versioned
  acts_as_paranoid_versioned
  has_many :memberships
  has_many :groups, :through => :memberships
  has_many :transactions

  # Virtual attribute for the unencrypted password
  attr_accessor :password

  validates_presence_of     :login
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..100
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  before_save :encrypt_password
  before_create :make_activation_code
  before_update :login_change

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password, check_activated = true)
    u = find_by_login(login) # need to get the salt
    #check for account activation using activated_at
    #u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login]
    
    return u && u.activated? && u.authenticated?(password) ? u : nil if check_activated
    return u && u.authenticated?(password) ? u : nil if !check_activated
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  def name
    return "#{self.first_name} #{self.last_name[0,1]}." if self.display_name.blank?
    self.display_name
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
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

  protected
    def validate
      errors.add("first_name", "cannot be blank if Display name is empty") if first_name.blank? && display_name.blank?
      errors.add("last_name", "cannot be blank if Display name is empty") if last_name.blank? && display_name.blank?
      errors.add("display_name", "cannot be blank if First Name and Last Name are empty") if display_name.blank? && first_name.blank? && last_name.blank?
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

    # If you're going to use activation, uncomment this too
    def make_activation_code
      self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
    end
    
    def login_change
      if User.find_by_id(id).login != login
        @login_changed = true
        make_activation_code
      end
    end
end
