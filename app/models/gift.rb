class Gift < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  has_one :deposit
  validates_presence_of :amount
  validates_numericality_of :amount
  has_one :user_transaction, :as => :tx
  validates_presence_of :to_email
  validates_presence_of :email
  before_create :make_pickup_code

  def sum
    super * -1
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
  
  protected
  def validate_on_create
    require 'iats/credit_card'
    if !credit_card_empty || user_id_empty
      errors.add_on_empty %w( first_name last_name address city province postal_code country credit_card expiry_month expiry_year card_expiry )
      errors.add("credit_card", "has invalid format") unless CreditCard.is_valid(credit_card)
      errors.add("credit_card", "is an unknown card type") unless CreditCard.cc_type(credit_card) != 'UNKNOWN'
      errors.add("card_expiry", "is in the past") if card_expiry && card_expiry < Date.today
    end
    if !user_id_empty && credit_card_empty
      errors.add("amount", "cannot be greater than your balance. Please make a deposit first or use your credit card.") unless amount != nil && self.user.balance > amount
    end
    super
  end

  def credit_card_empty
    credit_card == nil || ( credit_card.kind_of?(String) && credit_card.empty? )
  end

  def user_id_empty
    user_id == nil || ( user_id.kind_of?(String) && user_id.empty? )
  end

  def before_save
    self.credit_card = credit_card.to_s[-4, 4] if credit_card != nil
  end

  def make_pickup_code
    self.pickup_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end
end
