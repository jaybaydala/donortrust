require 'donortrust_mailer'

class TaxReceipt < ActiveRecord::Base
  belongs_to :user
  belongs_to :investment
  belongs_to :gift
  belongs_to :deposit

  # make all fields required
  validates_presence_of :email
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.email?}
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :province
  validates_presence_of :postal_code
  validates_presence_of :country
  validates_format_of   :country, :with => /^Canada$/i, :if => Proc.new { |gift| gift.country?}
  # validates_presence_of :user
  # validates_presence_of :investment

  def id_display
    return id.to_s.rjust(10,'0') if id
  end
end
