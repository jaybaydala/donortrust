class Order < ActiveRecord::Base
  has_many :investments
  has_many :gifts
  has_many :deposits
  has_one :tax_receipt
  belongs_to :user
  before_save :truncate_credit_card
  validates_uniqueness_of :order_number
  
  def initialize(params = nil)
    super
    self.donor_type ||= self.class.personal_donor
  end
  
  def self.personal_donor
    "personal"
  end
  def self.corporate_donor
    "corporate"
  end
  
  def credit_card_concealed
    "**** **** **** #{credit_card.to_s[-4, 4]}"
  end
  
  def account_balance_total=(val)
    write_attribute(:account_balance_total, strip_dollar_sign(val))
  end
  def credit_card_total=(val)
    write_attribute(:credit_card_total, strip_dollar_sign(val))
  end
  def total=(val)
    write_attribute(:total, strip_dollar_sign(val))
  end
  
  def card_expiry
    "#{expiry_month.to_s.rjust(2, "0")}/#{expiry_year}"
  end
  
  def validate_billing
    errors.add_on_blank(%w(donor_type first_name last_name address city postal_code province country email))
    errors.add_on_blank(:company) if self.donor_type? && self.donor_type == self.class.corporate_donor
    errors.add(:email, "isn't a valid email address") unless self.email? && self.email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    errors.empty?
  end
  
  def validate_payment(cart_items, current_balance = nil)
    minimum_credit_payment = minimum_credit_card_payment(cart_items, current_balance)
    errors.add(:credit_card_total, "must be at least #{number_to_currency(minimum_credit_payment)}") if self[:credit_card_total].to_f < minimum_credit_payment
    errors.add(:account_balance_total, "cannot be more than your current balance") if self[:account_balance_total].to_f > current_balance.to_f
    errors.add_to_base("Please ensure you're paying the full amount.") if (self[:credit_card_total].to_f + self[:account_balance_total].to_f) < self[:total].to_f
    errors.add_on_blank(%w(credit_card csc expiry_month expiry_year cardholder_name )) unless minimum_credit_payment == 0 # && account_balance_total.to_f == total.to_f
    errors.empty?
  end
  
  def minimum_credit_card_payment(cart_items, current_balance = nil)
    @minimum_credit_card_payment = 0
    cart_items.each{|item| @minimum_credit_card_payment += item.amount if item.class == Deposit}
    @minimum_credit_card_payment += self[:total].to_f - self[:account_balance_total].to_f if current_balance && current_balance > 0
    @minimum_credit_card_payment
  end
  
  def validate_confirmation(cart_items, current_balance = nil)
    # run through everything just to make sure...
    validate_billing
    validate_payment(cart_items, current_balance)
    errors.empty?
  end
  
  def run_transaction
    create_tax_receipt_from_order
    # use ActiveMerchant to process credit card
    # if successful
    #   set the authorization_result value
    #   create_tax_receipt_from_order
    # else
    #   handle the error
    # end
    true
  end
  
  def create_tax_receipt_from_order
    if self.credit_card_total?
      self.tax_receipt = TaxReceipt.new do |t|
        t.first_name   = self.first_name
        t.last_name    = self.last_name
        t.email        = self.email
        t.address      = self.address
        t.city         = self.city
        t.province     = self.province
        t.postal_code  = self.postal_code
        t.country      = self.country
        t.user_id      = self.user_id
      end
    end
  end
  
  def self.generate_order_number
    record = Object.new
    while record
      random = rand(999999999)
      record = find(:first, :conditions => ["order_number = ?", random])
    end
    return random
  end
  
  protected
  private
  def strip_dollar_sign(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    val.to_f
  end

  def truncate_credit_card
    self.credit_card = credit_card.to_s[-4, 4] if self.credit_card?
  end
end