require 'donortrust_mailer'

class TaxReceipt < ActiveRecord::Base
  belongs_to :user
  belongs_to :investment

  # make all fields required
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :province
  validates_presence_of :postal_code
  validates_presence_of :country
  validates_presence_of :user
  validates_presence_of :investment

  def id_display
    return id.to_s.rjust(10,'0') if id
  end

  def send_tax_receipt
    DonortrustMailer.deliver_tax_receipt(self)
  end
end
