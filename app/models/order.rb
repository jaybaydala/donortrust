require 'bigdecimal'
require 'active_merchant'
require 'iats/gateways/iats'
ActiveMerchant::Billing::Base.mode = RAILS_ENV == "production" ? :production : :test
class Order < ActiveRecord::Base
  has_many :investments
  has_many :gifts
  has_many :deposits
  
  has_many :pledges # added by joe
  
  has_one :tax_receipt
  belongs_to :user
  validates_uniqueness_of :order_number
  
  # virtual attribute for the entire card number
  attr_accessor :full_card_number
  
  def initialize(params = nil)
    super
    self.donor_type ||= self.class.personal_donor
    self.country ||= "Canada"
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
    @full_card_number = number# if !number.nil?
    write_attribute(:card_number, number) # clears it if it's nil
    write_attribute(:card_number, number.to_s[-4, 4]) if number # loads it back up if it's not
  end
  
  def card_number
    return @full_card_number if @full_card_number
    read_attribute(:card_number)
  end
  
  # set some accessor methods
  def account_balance_payment=(val)
    write_attribute(:account_balance_payment, strip_dollar_sign(val))
  end
  def credit_card_payment=(val)
    write_attribute(:credit_card_payment, strip_dollar_sign(val))
  end
  def gift_card_payment=(val)
    write_attribute(:gift_card_payment, strip_dollar_sign(val))
  end
  def total=(val)
    write_attribute(:total, strip_dollar_sign(val))
  end
  # set the reader methods for the columns dealing with currency
  # we're using BigDecimal explicity for mathematical accuracy - it's better for currency
  def account_balance_payment
    BigDecimal.new(read_attribute(:account_balance_payment).to_s) unless read_attribute(:account_balance_payment).nil?
  end
  def credit_card_payment
    BigDecimal.new(read_attribute(:credit_card_payment).to_s) unless read_attribute(:credit_card_payment).nil?
  end
  def gift_card_payment
    BigDecimal.new(read_attribute(:gift_card_payment).to_s) unless read_attribute(:gift_card_payment).nil?
  end
  def total
    BigDecimal.new(read_attribute(:total).to_s) unless read_attribute(:total).nil?
  end
  
  def card_expiry
    "#{expiry_month.to_s.rjust(2, "0")}/#{expiry_year}"
  end
  
  def validate_billing(cart_items)
    if tax_receipt_needed?
      required_fields = %w(donor_type first_name last_name address city postal_code province country email)
    else
      required_fields = %w(email)
    end
    errors.add_on_blank(required_fields)
    errors.add_on_blank(:company) if self.donor_type? && self.donor_type == self.class.corporate_donor
    if self.email? && !errors.on(:email)
      errors.add(:email, "isn't a valid email address") unless self.email =~ /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    end
    # credit_card_payment
    if credit_card_payment?
      unless credit_card.valid?
        credit_card_messages = credit_card.errors.full_messages.collect{|msg| "<li>#{msg}</li>"}
        errors.add_to_base("Your credit card information does not appear to be valid. Please correct it and try again:<ul>#{credit_card_messages.join}</ul>") 
      end
    end
    errors.empty?
  end
  
  attr_accessor :account_balance, :gift_card_balance
  def account_balance=(val)
    @account_balance = BigDecimal.new(val.to_s)
  end
  def gift_card_balance=(val)
    @gift_card_balance = BigDecimal.new(val.to_s)
  end
  def validate_payment(cart_items)
    errors.add(:account_balance_payment, "cannot be more than your current account balance") if @account_balance && @account_balance > 0 && account_balance_payment? && account_balance_payment > @account_balance
    errors.add(:gift_card_payment, "cannot be more than your current gift card balance") if @gift_card_balance && @gift_card_balance > 0 && gift_card_payment? && gift_card_payment > @gift_card_balance
    errors.add_to_base("Please ensure you're paying the full amount.") if total_payments < total
    errors.add_to_base("You only need to pay the cart total.") if total_payments > total
    errors.add_to_base("You must pay at least #{number_to_currency(minimum_credit_payment(cart_items))} from a credit card and/or gift card.") if minimum_credit_payment(cart_items) && minimum_credit_payment(cart_items) > credit_payments
    errors.empty?
  end

  def minimum_credit_payment(cart_items)
    if (account_balance && account_balance > 0) || (user_id? && user && user.balance > 0)
      @minimum_credit_payment = cart_items.inject(0) {|sum, item| sum + (item.class == Deposit ? item.amount : 0) }
    else
      @minimum_credit_payment = total
    end
    @minimum_credit_payment
  end
  
  def validate_confirmation(cart_items)
    # run through everything just to make sure...
    validate_payment(cart_items)
    validate_billing(cart_items)
    errors.empty?
  end
  
  def run_transaction
    if credit_card.valid?
      if File.exists?("#{RAILS_ROOT}/config/iats.yml")
        config = YAML.load(IO.read("#{RAILS_ROOT}/config/iats.yml"))
        gateway_login    = config["username"]
        gateway_password = config["password"]
      else
        gateway_login, gateway_password = nil
      end
      
      gateway = ActiveMerchant::Billing::IatsGateway.new(
        :login    => gateway_login,	
        :password => gateway_password
      )
      
      # purchase the amount
      purchase_options = {:billing_address => billing_address, :invoice_id => self.order_number}
      response = gateway.purchase(total*100, credit_card, purchase_options)
      if response.success?
        self.update_attributes({:authorization_result => response.authorization})
        create_tax_receipt_from_order if self.country.to_s.downcase == "canada"
      else
        raise ActiveMerchant::Billing::Error.new(response.message)
      end
      true
    else
      raise ActiveMerchant::Billing::Error.new
    end
  end
  
  def credit_card(use_iats=true)
    unless @credit_card
      # if we're using IATS gateway, set the currency to CAD
      # this requires cardholder_name and "un-requires" first name, last name
      if use_iats
        ActiveMerchant::Billing::CreditCard.canadian_currency = true
      end
      # Create a new credit card object
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number          => self.card_number,
        :month           => self.expiry_month,
        :year            => self.expiry_year,
        :cardholder_name => self.cardholder_name,
        :verification_value  => self.cvv
      )
    end
    @credit_card
  end
  def billing_address
    {
    :first_name   => self.first_name,
    :last_name    => self.last_name,
    :address      => self.address,
    :city         => self.city,
    :state        => self.province,
    :zip          => self.postal_code,
    :country      => self.country
    }
  end

  def create_tax_receipt_from_order
    if tax_receipt_needed?
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
        t.order_id     = self.id
      end
    end
  end
  
  def self.create_order_with_investment_from_project_gift(gift)
    return unless gift.project_id? && gift.project
    first_name, last_name = gift.to_name.to_s.split(/ /, 2)
    Order.transaction do
      order = Order.create!(
        :first_name => first_name,
        :last_name => last_name,
        :email => gift.to_email,
        :total => gift.amount,
        :gift_card_payment => gift.amount,
        :gift_card_payment_id => gift.id,
        :complete => true
      )
      order.investments = [Investment.create!(
        :amount => gift.amount,
        :project => gift.project,
        :gift_id => gift.id
      )]
      order
    end
  end
  
  def tax_receipt_needed?
    self.credit_card_payment?
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
  def credit_payments
    total = BigDecimal.new("0")
    total += credit_card_payment if credit_card_payment?
    total += gift_card_payment if gift_card_payment?
    total
  end
  def total_payments
    total = BigDecimal.new("0")
    total += credit_card_payment if credit_card_payment?
    total += gift_card_payment if gift_card_payment?
    total += account_balance_payment if account_balance_payment?
    total
  end
  
  private
  def strip_dollar_sign(val)
    val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
    val
  end
end