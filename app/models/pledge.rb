class Pledge < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :participant
  belongs_to :team
  belongs_to :campaign
  belongs_to :user
  has_one :pledge_deposit

  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount

  after_create :user_transaction_create

  # set the reader methods for the columns dealing with currency
  # we're using BigDecimal explicity for mathematical accuracy - it's better for currency
  def amount
    BigDecimal.new(read_attribute(:amount).to_s) unless read_attribute(:amount).nil?
  end

  def pledgee
    if (self.participant != nil)
      return self.participant.name
    elsif (self.team != nil)
      return self.team.name
    elsif (self.campaign != nil)
      return self.campaign.name
    end

    return nil
  end
end
