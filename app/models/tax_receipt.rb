require 'donortrust_mailer'

class TaxReceipt < ActiveRecord::Base
  belongs_to :user
  belongs_to :gift
  belongs_to :deposit
  belongs_to :order
  belongs_to :subscription

  before_create :make_view_code

  # make all fields required
  validates_presence_of :email
  validates_format_of   :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.email?}
  validates_presence_of :first_name
  validates_presence_of :last_name, :unless => Proc.new { |tr| tr.user.group? }
  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :province
  validates_presence_of :postal_code
  validates_presence_of :country
  validates_format_of   :country, :with => /^Canada$/i, :if => Proc.new{|r| r.country? }
  validates_numericality_of :amount, :greater_than => 0, :unless => Proc.new{|r| r.amount.nil? }

  def id_display
    return id.to_s.rjust(10,'0') if id
  end

  def total=(val)
    @total = BigDecimal.new(val.to_s)
  end

  def total
    unless @total
      if order
        @total = order.credit_card_payment
      elsif gift
        @total = gift.amount
      elsif deposit
        @total = deposit.amount
      else
        @total = amount
      end
    end
    @total
  end
  
  def make_view_code
    code = TaxReceipt.generate_view_code
    # ensure it's not currently being used
    unless TaxReceipt.find_by_view_code(code)
      self.view_code = code and return
    end
    # if we get here, it's being used, so try again
    make_view_code
  end
  
  def self.generate_view_code
    hash = ""
    srand()
    (1..12).each do
      rnd = (rand(2147483648)%36) # using 2 ** 31
      rnd = rnd<26 ? rnd+97 : rnd+22
      hash = hash + rnd.chr
    end
    hash
  end
end
