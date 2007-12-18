class Deposit < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :user
  belongs_to :gift
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id

  after_create :user_transaction_create, :tax_receipt_create
  
  def self.new_from_gift(gift, user_id)
    Deposit.new( :amount => gift.amount, :gift_id => gift.id, :user_id => user_id )
  end
  
  def sum
    #return 0 if self[:gift_id] && self.gift[:project_id]
    super
  end
   def self.dollars_deposited
    raised = 0
    self.find(:all).each do |desposit|
      raised = raised + desposit.amount
    end
    raised
  end

  protected
  def validate
    require 'iats/credit_card'
    if gift_id == nil
      errors.add_on_empty %w( credit_card card_expiry first_name last_name address city province postal_code country )
      errors.add("credit_card", "has invalid format") unless CreditCard.is_valid(credit_card)
      errors.add("credit_card", "is an unknown card type") unless CreditCard.cc_type(credit_card) != 'UNKNOWN'
      errors.add("card_expiry", "is in the past") if card_expiry && card_expiry < Date.today
    end
    super
  end

  def before_save
    self[:credit_card] = credit_card.to_s[-4, 4] if credit_card != nil
    if gift_id == nil
      errors.add_on_empty %w( authorization_result )
    end
    super
  end
  
  private
  def tax_receipt_create
    if credit_card? && country? && country.downcase == 'canada'
      @tax_receipt = TaxReceipt.new
      @tax_receipt.user = self.user if self.user
      @tax_receipt.email = self.user.login if self.user && self.user.login?
      @tax_receipt.first_name = self.first_name
      @tax_receipt.last_name = self.last_name
      @tax_receipt.address = self.address
      @tax_receipt.city = self.city    
      @tax_receipt.province = self.province
      @tax_receipt.postal_code = self.postal_code
      @tax_receipt.country = self.country    
      @tax_receipt.deposit_id = self.id    
      @tax_receipt.save
    end
  end
end
