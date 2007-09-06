class Deposit < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  has_one :user_transaction, :as => :tx
  serialize :user_hash
  
  def card_expiry=(value)
    if value.kind_of?(String)
      if value.match(/^\d\d\d\d$/)
        value = Array[ value[0,2], value[2,2] ]
      elsif value.match(/^\d{1,2}\/(\d\d)|(\d\d\d\d)$/)
        value = value.split('/')
      elsif value.match(/^\d\d \d\d$/)
        value = value.split(' ')
      end
    end
    if value && value.kind_of?(String)
      begin
        tmp = Date.parse(value)
        date = Date.civil(tmp.year, tmp.month, -1)
      rescue ArgumentError
        date = nil
      end
    elsif value && value.kind_of?(Array)
      year = value[1]
      year = (Date.today.year.to_s[0,2] + value[1]) if value[1].length == 2
      date = Date.civil(year.to_i, value[0].to_i, -1)
    elsif value && value.kind_of?(Date)
      tmp = value
      date = Date.civil(tmp.year, tmp.month, -1)
    end
    write_attribute(:card_expiry, date) if date
    return false if !date
  end
  
  def expiry_month
    self[:card_expiry].month if self[:card_expiry]
  end

  def expiry_year
    self[:card_expiry].year.to_s[-2, 2] if self[:card_expiry]
  end
  
  def sum
    amount
  end

  protected
  def validate
    require 'iats/credit_card'
    errors.add_on_empty %w( credit_card card_expiry )
    errors.add("credit_card", "has invalid format") unless CreditCard.is_valid(credit_card)
    errors.add("credit_card", "is an unknown card type") unless CreditCard.cc_type(credit_card) != 'UNKNOWN'
    errors.add("card_expiry", "is in the past") if card_expiry && card_expiry < Date.today
    super
  end

  def before_save
    credit_card = credit_card.to_s[ -4, 4 ]
    errors.add_on_empty %w( authorization_result )
  end
end
