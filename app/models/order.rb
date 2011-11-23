require 'bigdecimal'
require 'active_merchant'
require 'iats/gateways/iats'
ActiveMerchant::Billing::Base.mode = RAILS_ENV == "production" ? :production : :test
class Order < ActiveRecord::Base
  belongs_to :cart
  belongs_to :subscription
  belongs_to :user
  has_many :campaign_donations
  has_many :investments
  has_many :gifts
  has_many :deposits
  has_many :pledges # added by joe
  has_many :tips
  has_one :registration_fee
  has_one :tax_receipt

  # validates_presence_of :cart
  validates_presence_of :first_name,  :if => lambda {|r| r.billing_info_required? && (r.includes_subscription? || r.personal_donor?) }
  validates_presence_of :last_name,   :if => lambda {|r| r.billing_info_required? && (r.includes_subscription? || r.personal_donor?) }
  validates_presence_of :company,     :if => lambda {|r| r.billing_info_required? && r.corporate_donor? }
  validates_presence_of :donor_type,  :if => :billing_info_required?
  validates_presence_of :address,     :if => :billing_info_required?
  validates_presence_of :city,        :if => :billing_info_required?
  validates_presence_of :postal_code, :if => :billing_info_required?
  validates_presence_of :province,    :if => :billing_info_required?
  validates_presence_of :country,     :if => :billing_info_required?
  validates_presence_of :email, :unless => lambda {|r| r.upowered_step || r.payment_options_step }
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :allow_blank => true
  validates_uniqueness_of :order_number
  validates_numericality_of :account_balance_payment, :allow_nil => true
  validates_numericality_of :credit_card_payment, :allow_nil => true
  validates_numericality_of :gift_card_payment, :allow_nil => true
  validates_numericality_of :offline_fund_payment, :allow_nil => true
  validates_numericality_of :pledge_account_payment, :allow_nil => true
  validate do |order|
    if order.payment_options_step
      order.validate_payment
    end
    if order.account_signup_step
      if order.includes_subscription? || order.tax_receipt_needed?
        unless order.user
          user = order.build_user_from_order
          user.errors.full_messages.each{|msg| order.errors.add_to_base(msg) } unless user.valid?
        end
      end
    end
    if order.credit_card_step
      order.validate_credit_card
    end
  end

  before_create :generate_order_number
  before_save :add_upowered_to_cart
  after_save :update_user_information

  attr_accessor :upowered_step, :payment_options_step, :billing_step, :account_signup_step, :credit_card_step, :receipt_step, :upowered

  named_scope :complete, :conditions => { :complete => true }

  def validate_credit_card
    if credit_card_payment?
      unless credit_card.valid?
        credit_card_messages = credit_card.errors.full_messages.collect{|msg| " - #{msg}"}
        errors.add_to_base("Your credit card information does not appear to be valid. Please correct it and try again:#{credit_card_messages.join}") 
      end
    end
  end

  def validate_payment
    # validations for available balances
    errors.add(:account_balance_payment, "cannot be more than your current account balance") if @account_balance && @account_balance > 0 && account_balance_payment? && account_balance_payment > @account_balance
    errors.add(:gift_card_payment, "cannot be more than your current gift card balance") if @gift_card_balance && @gift_card_balance > 0 && gift_card_payment? && gift_card_payment > @gift_card_balance
    errors.add(:pledge_account_payment, "cannot be more than your current pledge account balance") if @pledge_account_balance && @pledge_account_balance > 0 && pledge_account_payment? && pledge_account_payment > @pledge_account_balance
    # check validity of the basic numbers
    errors.add(:gift_card_payment, "must be a positive number") if self.gift_card_payment? && self.gift_card_payment < 0
    errors.add(:account_balance_payment, "must be a positive number") if self.account_balance_payment? && self.account_balance_payment < 0
    errors.add(:pledge_account_payment, "must be a positive number") if self.pledge_account_payment? && self.pledge_account_payment < 0
    errors.add(:credit_card_payment, "must be a positive number") if self.credit_card_payment? && self.credit_card_payment < 0
    errors.add(:offline_fund_payment, "must be a positive number") if self.offline_fund_payment? && self.offline_fund_payment < 0
    # check validity of totals
    errors.add_to_base("Please ensure you're paying the full amount.") if total_payments < total
    errors.add_to_base("You only need to pay the cart total.") if total_payments > total
    errors.add_to_base("You must pay at least #{number_to_currency(minimum_credit_payment)} from a credit card and/or gift card.") if minimum_credit_payment && minimum_credit_payment > credit_payments
    errors.empty?
  end

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
    "**** **** **** #{card_number.to_s.rjust(4, " ")[-4, 4].strip}"
  end

  def line_items
    @line_items ||= self.gifts + self.investments + self.pledges + self.deposits + self.tips
  end

  def multiline_address
    @multiline_address = []
    @multiline_address << address if address?
    @multiline_address << address2 if address2?
    @multiline_address << sprintf("%s, %s %s", city, province, postal_code) if city? && province? && postal_code?
    @multiline_address << country if @multiline_address.present? && country?
    @multiline_address
  end

  def name
    if corporate_donor?
      self.company
    else
      "#{title} #{self.first_name} #{self.last_name}"
    end
  end

  # for member signup
  attr_accessor :password, :password_confirmation, :terms_of_use
  def create_user_from_order
    if self.password.present? && !self.user
      user = build_user_from_order
      user.save
      user.activate
      user
    end
  end

  def build_user_from_order
    user = User.new
    user.login = self.email
    user.display_name = "#{self.first_name} #{self.last_name.to_s[0, 1]}"
    user.address = self.address
    user.city = self.city
    user.province = self.province
    user.postal_code = self.postal_code
    user.country = self.country
    user.password = self.password
    user.password_confirmation = self.password_confirmation
    user.terms_of_use = self.terms_of_use
    user
  end

  def corporate_donor?
    self.donor_type == self.class.corporate_donor
  end

  def personal_donor?
    self.donor_type == self.class.personal_donor
  end

  # card number temporarily held in tmp_card_number
  attr_accessor :full_card_number
  def card_number=(number)
    # self.tmp_card_number = number
    @full_card_number = number
    write_attribute(:card_number, number) # clears it if it's nil
    # this is a bit fancy schmancy - just so we can test with "1" for the card_number
    write_attribute(:card_number, number.to_s.rjust(4, " ")[-4, 4].strip) if number # loads it back up if it's not
  end

  def card_number
    # return self.tmp_card_number if self.tmp_card_number?
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
  def offline_fund_payment=(val)
    val = nil if self.user.blank?
    val = nil if self.user && !self.user.cf_admin?
    write_attribute(:offline_fund_payment, (val.nil? ? val : strip_dollar_sign(val)) )
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
  
  attr_accessor :account_balance, :gift_card_balance, :pledge_account_balance
  def account_balance=(val)
    @account_balance = BigDecimal.new(val.to_s)
  end
  def gift_card_balance=(val)
    @gift_card_balance = BigDecimal.new(val.to_s)
  end
  def pledge_account_balance=(val)
    @pledge_account_balance = BigDecimal.new(val.to_s)
  end

  def minimum_credit_payment
    cart_items = self.cart.items
    if (account_balance && account_balance > 0) || 
        (user_id? && user && user.balance > 0) || 
        (user_id? && user.pledge_accounts && user.pledge_accounts.inject(0){|sum,pa| sum+=pa.balance} > 0)
      @minimum_credit_payment = cart_items.inject(0) {|sum, ci| sum + (ci.item.class == Deposit ? ci.item.amount : 0) }
    else
      @minimum_credit_payment = total
    end
    @minimum_credit_payment -= offline_fund_payment if offline_fund_payment?
    @minimum_credit_payment
  end

  def validate_confirmation
    # run through everything just to make sure...
    validate_payment
    validate_credit_card
    errors.empty?
  end

  def run_transaction
    logger.debug("Entering run_transaction")
    if credit_card.valid?
      if File.exists?("#{RAILS_ROOT}/config/iats.yml")
        config = YAML.load(IO.read("#{RAILS_ROOT}/config/iats.yml"))
        gateway_login    = config["username"]
        gateway_password = config["password"]
      else
        gateway_login, gateway_password = nil
      end
      
      gateway = ActiveMerchant::Billing::Base.gateway('iats').new(
        :login    => gateway_login,	
        :password => gateway_password
      )
      
      # purchase the amount
      purchase_options = {:billing_address => billing_address, :invoice_id => self.order_number}
      logger.debug("Transacting purchase for #{self.credit_card_payment.to_s}")
      response = gateway.purchase(self.credit_card_payment*100, credit_card, purchase_options)
      if response.success?
        self.update_attributes({:authorization_result => response.authorization})
        create_tax_receipt_from_order if self.country.to_s.downcase == "canada"
      else
        raise ActiveMerchant::Billing::Error.new(response.message)
      end
      true
    else
      raise ActiveMerchant::Billing::Error.new("There was an error with the credit card.")
    end
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

  def billing_info_required?
    (includes_subscription? || tax_receipt_requested?) && (!payment_options_step && !upowered_step)
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
        :number          => @full_card_number || self.card_number,
        :month           => self.expiry_month,
        :year            => self.expiry_year,
        :cardholder_name => self.cardholder_name,
        :verification_value  => self.cvv
      )
    end
    @credit_card
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
        :tax_receipt_requested => false,
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

  def self.transfer_balance(from_user, to_user)
    if from_user.balance > 0
      Order.transaction do
        order = Order.new
        order.user = from_user
        order.first_name = from_user.first_name
        order.last_name = from_user.last_name
        order.email = from_user.login
        order.account_balance_payment = from_user.balance
        order.transfer = true
        order.deposits.build(:amount => from_user.balance, :user => to_user)
        order.save!
        order.update_attribute(:complete, true)
        order
      end
    end
  end

  def created_subscription?
    !!Subscription.find_by_order_id(self.id)
  end

  def includes_subscription?
    self.cart && self.cart.subscription?
  end

  def subscription_item
    self.cart.subscription.item if self.includes_subscription?
  end

  def has_gift_card?
    return false if !self.cart.present?

    self.cart.has_gift_card?
  end

  def has_tip?
    self.cart && self.cart.has_tip?
  end

  def tip_item
    self.cart.tip_item
  end

  def tip_percent
    if self.tip_item.present?
      (self.tip_item.amount / self.total)*100
    else
      0
    end
  end

  def tax_receipt_needed?
    self.tax_receipt_requested? && self.credit_card_payment?
  end
  
  def generate_order_number
    self.order_number = Order.generate_order_number
  end
  def self.generate_order_number
    record = Object.new
    while record
      random = rand(999999999)
      record = find(:first, :conditions => ["order_number = ?", random])
    end
    return random
  end
  
  def total_payments
    total = BigDecimal.new("0")
    total += credit_card_payment if credit_card_payment?
    total += gift_card_payment if gift_card_payment?
    total += account_balance_payment if account_balance_payment?
    total += pledge_account_payment if pledge_account_payment?
    total += offline_fund_payment if offline_fund_payment?
    total
  end

  protected

    def add_upowered_to_cart
      if self.upowered.present? && Project.admin_project
        cart.add_upowered(self.upowered["amount"], self.user)
      end
    end

    def credit_payments
      total = BigDecimal.new("0")
      total += credit_card_payment if credit_card_payment?
      total += gift_card_payment if gift_card_payment?
      total
    end
  
  private
    def strip_dollar_sign(val)
      val = val.to_s.sub(/^\$/, '') if val.to_s.match(/^\$/)
      val
    end

    def update_user_information
      if self.complete? && user = self.user
        user.first_name ||= self.first_name
        user.last_name ||= self.last_name
        user.address ||= self.address
        user.city ||= self.city
        user.province ||= self.province
        user.postal_code ||= self.postal_code
        user.country ||= self.country
        user.save
      end
    end
end
