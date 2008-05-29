require 'active_merchant'
ActiveMerchant::Billing::Base.mode = RAILS_ENV == "production" ? :production : :test
class Order < ActiveRecord::Base
  has_many :investments
  has_many :gifts
  has_many :deposits
  has_one :tax_receipt
  belongs_to :user
  validates_uniqueness_of :order_number
  
  # virtual attribute for the entire card number
  attr_accessor :full_card_number
  
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
  
  def card_number_concealed
    "**** **** **** #{card_number.to_s[-4, 4]}"
  end
  
  def card_number=(number)
    @full_card_number = number if !number.nil?
    write_attribute(:card_number, number)
    write_attribute(:card_number, number.to_s[-4, 4]) if number
  end
  
  def card_number
    return @full_card_number if @full_card_number
    read_attribute(:card_number)
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
    if self.email? && !errors.on(:email)
      errors.add(:email, "isn't a valid email address") unless self.email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    end
    errors.empty?
  end
  
  def validate_payment(cart_items, current_balance = nil)
    minimum_credit_payment = minimum_credit_card_payment(cart_items, current_balance)
    errors.add(:credit_card_total, "must be at least #{number_to_currency(minimum_credit_payment)}") if self[:credit_card_total].to_f < minimum_credit_payment
    errors.add(:account_balance_total, "cannot be more than your current balance") if self[:account_balance_total].to_f > current_balance.to_f
    errors.add_to_base("Please ensure you're paying the full amount.") if (self[:credit_card_total].to_f + self[:account_balance_total].to_f) < self[:total].to_f
    if minimum_credit_payment > 0 || credit_card_total?
      unless credit_card.valid?
        credit_card_messages = credit_card.errors.full_messages.collect{|msg| "<li>#{msg}</li>"}
        errors.add_to_base("Your credit card information does not appear to be valid. Please correct it and try again:<ul>#{credit_card_messages.join}</ul>") 
      end
    end
    errors.empty?
  end
  
  def minimum_credit_card_payment(cart_items, current_balance = nil)
    total = self[:total].to_f
    current_balance = current_balance.to_f
    if !current_balance
      @minimum_credit_card_payment = total
    else
      deposit_balance = 0
      cart_items.each{|item| deposit_balance += item.amount if item.class == Deposit}
      @minimum_credit_card_payment = deposit_balance
      subtotal = total - deposit_balance # this is what's left
      if current_balance < subtotal
         @minimum_credit_card_payment += subtotal - current_balance
      end
    end
    @minimum_credit_card_payment
  end
  
  def validate_confirmation(cart_items, current_balance = nil)
    # run through everything just to make sure...
    validate_billing
    validate_payment(cart_items, current_balance)
    errors.empty?
  end
  
  def run_transaction
    create_tax_receipt_from_order if @order.country.to_s.downcase == "canada"
    # use ActiveMerchant to process credit card
    # if successful
    #   set the authorization_result value
    #   create_tax_receipt_from_order
    # else
    #   handle the error and raise the message exception?
    # end
    true
  end
  
  def credit_card
    unless @credit_card
      first_name, last_name = self.cardholder_name.split(/ /, 2)
      # Create a new credit card object
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number     => self.card_number,
        :month      => self.expiry_month,
        :year       => self.expiry_year,
        :first_name => first_name,
        :last_name  => last_name,
        :verification_value  => self.cvv
      )
    end
    @credit_card
  end

  def create_tax_receipt_from_order
    if self.credit_card_total?
      self.tax_receipt.create do |t|
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
end