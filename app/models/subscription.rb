require 'bigdecimal'
require 'active_merchant'
require 'iats/gateways/iats'
require 'iats/gateways/iats_reoccuring'
ActiveMerchant::Billing::Base.mode = Rails.env == "production" ? :production : :test

class Subscription < ActiveRecord::Base
  belongs_to :user
  # belongs_to :project
  has_many :line_items, :class_name => "SubscriptionLineItem"
  has_many :orders
  before_create :create_customer
  before_update :update_customer
  before_destroy :delete_customer
  attr_accessor :full_card_number
  
  def card_number=(number)
    @full_card_number = number
    write_attribute(:card_number, number) # clears it if it's nil
    write_attribute(:card_number, number.to_s[-4, 4]) if number # loads it back up if it's not
  end
  
  def card_number
    return @full_card_number if @full_card_number
    read_attribute(:card_number)
  end

  def self.create_from_cart_and_order(cart, order)
    subscription = self.new
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

    subscription.card_number = order.card_number
    subscription.cvv = order.cvv
    subscription.expiry_month = order.expiry_month
    subscription.expiry_year = order.expiry_year

    subscription.amount = order.total

    subscription.reoccurring_status = false # we will do the reoccurring manually - see config/schedules.rb
    subscription.begin_date = Date.today
    subscription.end_date = Date.today + 10.years
    subscription.schedule_type = "MONTHLY"
    subscription.schedule_date = Date.today.day
    
    subscription.tax_receipt_requested = order.tax_receipt_requested
    
    subscription.save!

    cart.items.each do |cart_line_item|
      subscription.line_items.create(:item_type => cart_line_item.item_type, :item_attributes => cart_line_item.item_attributes)
    end
    
    subscription
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

  def process_payment
    purchase_options = { :invoice_id => order.id }
    logger.debug("purchase_options: #{purchase_options.inspect}")
    response = gateway.purchase_with_customer_code(self.amount, self.customer_code, purchase_options)
    if response.success?
      order.update_attributes({:authorization_result => response.authorization})
      order.create_tax_receipt_from_order if order.country.to_s.downcase == "canada"
      self.line_items.each do |line_item|
        item = line_item.item
        item.order_id = order.id
        item.save!
      end
    else
      raise ActiveMerchant::Billing::Error.new(response.message)
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
                              :customer_code => self.customer_code,
                              :invoice_id => self.id
                            }
        logger.debug("purchase_options: #{purchase_options.inspect}")
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
      response = gateway.update_customer(self.customer_code)
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
          gateway_login, gateway_password = nil
        end
    
        @gateway = ActiveMerchant::Billing::IatsReoccuringGateway.new(
          :login    => gateway_login,	
          :password => gateway_password
        )
      end
      @gateway
    end
end