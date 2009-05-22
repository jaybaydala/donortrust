class RegistrationFee < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :order
  belongs_to :participant
  
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount

  validates_presence_of :participant

  after_create :user_transaction_create

  # set the reader methods for the columns dealing with currency
  # we're using BigDecimal explicity for mathematical accuracy - it's better for currency
  def amount
    BigDecimal.new(read_attribute(:amount).to_s) unless read_attribute(:amount).nil?
  end

  def campaign
    participant.team.campaign
  end

  def project
    Projects.find(:first, :conditions => {:id => 10})
  end

end