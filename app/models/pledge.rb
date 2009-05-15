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

  def valid?
    if not self.campaign.valid?
      return false
    end

    if not super.participant.nil?
      if not super.team.nil? or not super.campaign.nil?
        return false
      end

    elsif not super.team.nil?
      if not super.participant.nil? or not super.campaign.nil?
        return false
      end

    elsif not super.campaign.nil?
      if not super.participant.nil? or not super.team.nil?
        return false
      end
    end

    return super.valid?
  end

  def campaign
    if not self.participant.nil?
      return participant.team.campaign
    elsif not self.team.nil?
      return team.campaign
    elsif not self.campaign.nil?
      return campaign
    end
  end

  def team
    if not self.participant.nil?
      return participant.team
    elsif not self.team.nil?
      return self.team
    end

    return nil
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
