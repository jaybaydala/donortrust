class Order < ActiveRecord::Base
  has_many :investments
  has_many :gifts
  has_many :deposits
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
    val = strip_dollar_sign(val)
    super(val)
  end
  def credit_card_total=(val)
    val = strip_dollar_sign(val)
    super(val)
  end
  def total=(val)
    val = strip_dollar_sign(val)
    super(val)
  end
  
  def card_expiry
    "#{expiry_month.to_s.rjust(2, "0")}/#{expiry_year}"
  end
  
  def validate_billing
    errors.add_on_blank(%w(donor_type title first_name last_name address city postal_code province country email))
    errors.add(:email, :message => "isn't a valid email address") unless self[:email].to_s =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    errors.empty?
  end
  
  def validate_payment(minimum_credit_card_payment, current_balance = nil)
    errors.add(:credit_card_total, "must be at least the value of the deposits") if self[:credit_card_total].to_f < minimum_credit_card_payment.to_f
    unless current_balance.nil?
      errors.add(:account_balance_total, "cannot be more than your current balance") if self[:account_balance_total].to_f > current_balance
    end
    errors.add_to_base("Please ensure you're paying the full amount.") if self[:total].to_f > (self[:credit_card_total].to_f + self[:account_balance_total].to_f)
    errors.add_on_blank(%w(credit_card csc expiry_month expiry_year cardholder_name )) if minimum_credit_card_payment > 0 || account_balance_total < total
    errors.empty?
  end
  
  def validate_confirmation
    errors.empty?
  end
  
  private
  def strip_dollar_sign(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
  end

  def truncate_credit_card
    self.credit_card = credit_card.to_s[-4, 4] if self.credit_card?
  end
end