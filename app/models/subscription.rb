require 'bigdecimal'
require 'active_merchant'
require 'iats/gateways/iats'
require 'iats/gateways/iats_reoccuring'
ActiveMerchant::Billing::Base.mode = Rails.env == "production" ? :production : :test

class Subscription < ActiveRecord::Base
  belongs_to :order
  belongs_to :user
  # belongs_to :project
  has_many :line_items, :class_name => "SubscriptionLineItem"
  has_many :orders
  has_many :tax_receipts

  validates_presence_of :donor_type, :first_name, :last_name, :address, :city, :province, :postal_code, :country, :email
  validates_format_of :email, :message => "isn't a valid email address", :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validate do |s|
    s.errors.add(:end_date, "must be set into the future") unless s.end_date? && s.end_date > Date.today
    unless s.credit_card.valid?
      credit_card_messages = s.credit_card.errors.full_messages.collect{|msg| " - #{msg}"}
      s.errors.add_to_base("Your credit card information does not appear to be valid. Please correct it and try again:#{credit_card_messages.join}") 
    end
  end

  before_create :create_customer
  before_update :update_customer
  before_destroy :delete_customer
  
  named_scope :current, lambda { { :conditions => ['begin_date <= ? && (end_date IS NULL OR end_date >= ?)', Date.today, Date.today] } }
  named_scope :tax_receiptable, { :conditions => { :tax_receipt_requested => true } }

  attr_accessor :full_card_number

  class << self
    def notify_impending_card_expirations
      Subscription.all(:conditions => ['expiry_month = ? AND expiry_year = ?', Date.today.month, Date.today.year]).each do |subscription|
        DonortrustMailer.deliver_impending_subscription_card_expiration_notice(subscription)
      end
    end

    def create_from_order(order)
      subscription = self.new
      # billing info
      subscription.order = order
      subscription.user = order.user
      subscription.donor_type = order.donor_type
      subscription.title = order.title
      subscription.first_name = order.first_name
      subscription.last_name = order.last_name
      subscription.company = order.company
      subscription.address = order.address
      subscription.address2 = order.address2
      subscription.city = order.city
      subscription.country = order.country
      subscription.province = order.province
      subscription.postal_code = order.postal_code
      subscription.email = order.email
      # tax receipt
      subscription.tax_receipt_requested = order.tax_receipt_requested
      # credit card info
      subscription.card_number = order.card_number
      subscription.cvv = order.cvv
      subscription.expiry_month = order.expiry_month
      subscription.expiry_year = order.expiry_year
      # total
      subscription.amount = order.subscription_item.amount
      # subscription details
      subscription.reoccurring_status = false # we will do the reoccurring manually - see config/schedules.rb
      subscription.begin_date = Date.today
      subscription.end_date = Date.today + 10.years
      subscription.schedule_type = "MONTHLY"
      subscription.schedule_date = Date.today.day
      # save!
      subscription.save!
      # add cart subcription line_item to the line_items
      subscription_line_item = order.cart.subscription
      subscription.line_items.create(:item_type => subscription_line_item.item_type, :item_attributes => subscription_line_item.item_attributes)
      subscription
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

  def card_number=(number)
    @full_card_number = number
    write_attribute(:card_number, (number.present? ? number.to_s.rjust(4, " ")[-4, 4].strip : nil))
  end
  
  def card_number
    return @full_card_number if @full_card_number
    read_attribute(:card_number)
  end

  def complete_payment(success, order)
    if success
      self.line_items.each do |line_item|
        item = line_item.item
        item.order_id = order.id
        item.save
      end
      order.update_attribute(:complete, true)
      DonortrustMailer.deliver_subscription_thanks(self)
    else
      DonortrustMailer.deliver_subscription_failure(self)
    end
  end

  def create_yearly_tax_receipt(year = Date.today.year-1, tax_receipt = nil)
    return unless self.tax_receipt_requested?
    yearly_total = yearly_tax_receiptable_total(year)
    return unless yearly_total > 0
    tax_receipt ||= TaxReceipt.new
    tax_receipt.tap do |t|
      t.first_name   = self.first_name
      t.last_name    = self.last_name
      t.email        = self.email
      t.address      = self.address
      t.city         = self.city
      t.province     = self.province
      t.postal_code  = self.postal_code
      t.country      = self.country
      t.user_id      = self.user_id
      t.amount       = yearly_total
      t.received_on  = Date.civil(year, 12, 31)
      t.subscription = self
    end
    tax_receipt.save
    tax_receipt.new_record? ? nil : tax_receipt
  end

  def credit_card(use_iats=true)
    unless @credit_card
      ActiveMerchant::Billing::CreditCard.canadian_currency = true if use_iats
      # Create a new credit card object
      @credit_card = ActiveMerchant::Billing::CreditCard.new(
        :number          => self.card_number,
        :month           => self.expiry_month,
        :year            => self.expiry_year,
        :first_name      => self.first_name,
        :last_name       => self.last_name,
        :cardholder_name => "#{self.first_name} #{self.last_name}",
        :verification_value  => self.cvv
      )
    end
    @credit_card
  end

  def end_subscription
    Subscription.transaction do
      begin
        column = self.connection.quote_column_name('end_date')
        value = self.connection.quote(Date.today.to_s(:db))
        self.class.update_all("#{column} = #{value}", { :id => self.id })
        delete_customer
      rescue ActiveMerchant::Billing::Error => exception
        return false
      end
      true
    end
  end

  def orders_for_year(year)
    self.orders.complete.for_year(year).all
  end

  def prepare_order
    order = Order.new
    order.user = self.user
    order.donor_type = self.donor_type
    order.title = self.title
    order.first_name = self.first_name
    order.last_name = self.last_name
    order.company = self.company
    order.address = self.address
    order.address2 = self.address2
    order.city = self.city
    order.country = self.country
    order.province = self.province
    order.postal_code = self.postal_code
    order.email = self.email

    order.total = self.amount
    order.credit_card_payment = order.total
    order.tax_receipt_requested = self.tax_receipt_requested
    order.subscription = self
    order.save
    order
  end

  def process_payment
    order = prepare_order
    purchase_options = { :invoice_id => order.id }
    logger.debug("purchase_options: #{purchase_options.inspect}")
    response = gateway.purchase_with_customer_code(self.amount*100, self.customer_code, purchase_options)
    order.update_attributes({:authorization_result => response.authorization}) if response.success?
    complete_payment(response.success?, order)
    raise ActiveMerchant::Billing::Error.new(response.inspect) unless response.success?
    order
  end

  def yearly_total(year)
    orders_for_year(year).inject(0) do |sum, order|
      sum += order.total
    end
  end

  def yearly_tax_receiptable_total(year)
    orders_for_year(year).inject(0) do |sum, order|
      sum += order.tax_receipt_requested? ? order.total : 0
    end
  end

  private
    def create_customer
      return true unless self.customer_code.nil?
      logger.debug("Entering Subscription::create_customer")
      logger.debug("credit_card: #{credit_card.inspect}")
      logger.debug("credit_card valid: #{credit_card.valid?}")
      logger.debug("credit_card errors: #{credit_card.errors.inspect}")
      if credit_card.valid?
        # purchase the amount
        logger.debug("attributes: #{self.attributes.inspect}")
        purchase_options = {
                              :reoccurring_status => self.reoccurring_status,
                              :begin_date => self.begin_date,
                              :end_date => self.end_date,
                              :schedule_type => self.schedule_type,
                              :schedule_date => self.schedule_date,
                              :billing_address => billing_address, 
                              :invoice_id => self.id
                            }
        logger.debug("purchase_options: #{purchase_options.inspect}")
        response = gateway.create_customer(amount*100, credit_card, purchase_options)
        if response.success?
          self.customer_code = response.authorization
        else
          raise ActiveMerchant::Billing::Error.new(response.message)
        end
        true
      else
        raise ActiveMerchant::Billing::Error.new("There was an error with the credit card.")
      end
    end
  
    def update_customer
      logger.debug("Entering Subscription::update_customer")
      logger.debug("credit_card: #{credit_card.inspect}")
      logger.debug("credit_card valid: #{credit_card.valid?}")
      logger.debug("credit_card errors: #{credit_card.errors.inspect}")

      purchase_options = {
                            :reoccurring_status => self.reoccurring_status,
                            :begin_date => self.begin_date,
                            :end_date => self.end_date,
                            :schedule_type => self.schedule_type,
                            :schedule_date => self.schedule_date,
                            :billing_address => billing_address, 
                            :customer_code => self.customer_code,
                            :invoice_id => self.id
                          }
      logger.debug("purchase_options: #{purchase_options.inspect}")

      if credit_card.valid?
        logger.debug("attributes: #{self.attributes.inspect}")
        response = gateway.update_customer(amount*100, self.customer_code, credit_card, purchase_options)
        if !response.success?
          raise ActiveMerchant::Billing::Error.new(response.message)
        end
        true
      else
        raise ActiveMerchant::Billing::Error.new("There was an error with the credit card.")
      end
    end

    def delete_customer
      response = gateway.delete_customer(self.customer_code)
      if !response.success?
        raise ActiveMerchant::Billing::Error.new(response.message)
      end
      true
    end
    
    def gateway
      unless @gateway
        if File.exists?("#{RAILS_ROOT}/config/iats.yml")
          config = YAML.load(IO.read("#{RAILS_ROOT}/config/iats.yml"))
          gateway_login    = config["username"]
          gateway_password = config["password"]
        else
          gateway_login = gateway_password = nil
        end
    
        @gateway = ActiveMerchant::Billing::IatsReoccuringGateway.new(
          :login    => gateway_login,	
          :password => gateway_password
        )
      end
      @gateway
    end
end