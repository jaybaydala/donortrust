require 'digest/sha1'
class BusUser < ActiveRecord::Base
  # Virtual attribute for the unencrypted password
  belongs_to :bus_user_type
  #has_many :projects, :through => :programs
  attr_accessor :password
  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end
  def current_user
    session[:user_id]
  end
  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
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
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end
  def to_label
    "#{login}"
  end

  def update_password(new_password,current_password)
    
    if(BusUser.encrypt(current_password,self.salt) == self.crypted_password)
      @temporary_hashed_password = BusUser.encrypt(new_password,self.salt)
      self.crypted_password = @temporary_hashed_password
      update
     return true
    else
      return false
    end
  end

  def to_label
    "#{login}"
  end
  
   def reset_pass(temp)
      new_encrypted_password(temp)
      update      
    end
  
  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end
    
    def new_encrypted_password(password)
      self.crypted_password = encrypt(password)
    end
    
   
end
