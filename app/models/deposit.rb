class Deposit < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  belongs_to :gift
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  has_one :user_transaction, :as => :tx
  
  def self.create_from_gift(gift, user_id)
    Deposit.create( :amount => gift.amount, :gift_id => gift.id, :user_id => user_id )
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
    credit_card = credit_card.to_s[ -4, 4 ] if credit_card != nil
    if gift_id == nil
      errors.add_on_empty %w( authorization_result )
    end
  end
end
