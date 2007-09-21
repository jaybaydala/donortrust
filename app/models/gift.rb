require 'digest/sha1'
class Gift < ActiveRecord::Base
  include UserTransactionHelper

  before_create :make_pickup_code

  belongs_to :user
  belongs_to :project
  has_one :deposit
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :to_email, :email
  validates_confirmation_of :to_email, :email, :on => :create
  validates_uniqueness_of :pickup_code, :allow_nil => :true
  
  def sum
    return credit_card ? 0 : super * -1
  end

  def self.validate_pickup(pickup_code, id=nil)
    return nil if pickup_code == nil || pickup_code.empty?
    gift = find_by_id_and_pickup_code(id, pickup_code, :conditions => { :picked_up_at => nil }) if id != nil
    gift = find_by_pickup_code(pickup_code, :conditions => { :picked_up_at => nil }) if id == nil
    gift
  end
  
  def pickup
    @picked_up = true if update_attributes(:picked_up_at => Time.now.utc, :pickup_code => nil)
  end
  
  def picked_up?
    @picked_up || false
  end
  
  def send_gift_mail
    @sent = true if update_attributes(:sent_at => Time.now.utc)
    DonortrustMailer.deliver_gift_mail(self)
  end
  
  def send_gift_mail?
    return new_record? == false && self[:send_at] == nil ? true : false
  end
  
  protected
  def validate_on_create
    require 'iats/credit_card'
    if !emptyval?(credit_card) || emptyval?(user_id)
      errors.add_on_empty %w( first_name last_name address city province postal_code country credit_card expiry_month expiry_year card_expiry )
      errors.add("credit_card", "has invalid format") unless CreditCard.is_valid(credit_card)
      errors.add("credit_card", "is an unknown card type") unless CreditCard.cc_type(credit_card) != 'UNKNOWN'
      errors.add("card_expiry", "is in the past") if card_expiry && card_expiry < Date.today
    end
    if !emptyval?(user_id) && emptyval?(credit_card)
      errors.add("amount", "cannot be greater than your balance. Please make a deposit first or use your credit card.") unless amount != nil && self.user.balance > amount
    end
    super
  end
  
  def validate
    errors.add("send_at", "must be in the future") if !emptyval?(send_at) && send_at.to_i <= Time.now.to_i
    super
  end

  def emptyval?(value)
    value == nil || ( value.kind_of?(String) && value.empty? )
  end

  def before_save
    self.credit_card = credit_card.to_s[-4, 4] if credit_card != nil
  end

  def make_pickup_code
    code = Gift.generate_pickup_code
    # ensure it's not currently being used
    if !Gift.find_by_pickup_code(code)
      self.pickup_code = code and return
    end
    # if we get here, it's being used, so try again
    make_pickup_code
  end
  
  def self.generate_pickup_code
    hash = ""
    srand()
    (1..12).each do
      rnd = (rand(2147483648)%36) # using 2 ** 31
      rnd = rnd<26 ? rnd+97 : rnd+22
      hash = hash + rnd.chr
    end
    hash
  end
end
