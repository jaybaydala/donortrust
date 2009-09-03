class PartnerPayment < ActiveRecord::Base
  has_one :partner

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :partner_id
  validates_presence_of :cheque_date
end
