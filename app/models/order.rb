class Order < ActiveRecord::Base
  has_many :investments
  has_many :gifts
  has_many :deposits
  has_one :tax_receipt
  before_save :truncate_credit_card

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
    errors.add(:email, :message => "isn't a valid email address") unless self[:email].to_s =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    errors.empty?
  end
  
  def validate_payment(minimum_credit_card_payment, current_balance = nil)
    errors.add(:credit_card_total, "must be at least the value of the deposits") if self[:credit_card_total].to_f < minimum_credit_card_payment.to_f
    unless current_balance.nil?
      errors.add(:account_balance_total, "cannot be more than your current balance") if self[:account_balance_total].to_f > current_balance
    end
    errors.add_to_base("Please ensure you're paying the full amount.") if self[:total].to_f > (self[:credit_card_total].to_f + self[:account_balance_total].to_f)
    errors.add_on_blank(%w(credit_card csc expiry_month expiry_year cardholder_name )) if minimum_credit_card_payment.to_f > 0 || account_balance_total.to_f < total
    errors.empty?
  end
  
  def validate_confirmation
    errors.empty?
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
      random = rand(9999999999)
      record = find(:first, :conditions => ["order_number = ?", random])
    end
    return random
  end
  
  private
  def strip_dollar_sign(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    val.to_f
  end

  def truncate_credit_card
    self.credit_card = credit_card.to_s[-4, 4] if self.credit_card?
  end
end