require 'digest/sha1'
class Gift < ActiveRecord::Base
  include UserTransactionHelper

  before_create :make_pickup_code

  belongs_to :user
  belongs_to :project
  belongs_to :e_card
  has_one :deposit
  has_one :user_transaction, :as => :tx
#  has_many :gift_lists

  validates_presence_of :amount
  validates_numericality_of :amount, :if => Proc.new { |gift| gift.amount?}
  validates_presence_of :to_email, :email
  validates_confirmation_of :to_email, :email, :on => :create
  validates_format_of   :to_email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.to_email?}
  validates_format_of   :email,       :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.email?}
  validates_uniqueness_of :pickup_code, :allow_nil => :true
  validates_numericality_of :project_id, :only_integer => true, :if => Proc.new { |gift| gift.project_id?}
  
  before_validation :trim_mailtos
  after_create :user_transaction_create, :tax_receipt_create
  
  
  def sum
    return credit_card ? 0 : super * -1
  end

  def self.validate_pickup(pickup_code, id=nil)
    return nil if pickup_code == nil || pickup_code.empty?
    gift = find_by_id_and_pickup_code(id, pickup_code, :conditions => { :picked_up_at => nil }) if id != nil
    gift = find_by_pickup_code(pickup_code, :conditions => { :picked_up_at => nil }) if id == nil
    gift
  end
  
  def pickup
    @picked_up = true if update_attributes(:picked_up_at => Time.now.utc, :pickup_code => nil)
  end
  
  def picked_up?
    @picked_up || false
  end
  
  def send_gift_mail
    if update_attributes(:sent_at => Time.now.utc)
      DonortrustMailer.deliver_gift_mail(self)
      @sent = true
    end
  end
  
  def send_gift_confirm
    DonortrustMailer.deliver_gift_confirm(self)
  end

  def send_gift_resend
    DonortrustMailer.deliver_gift_resendPDF(self)
  end

  def send_gift_reminder
    DonortrustMailer.deliver_gift_expiry_notifier(self)
    DonortrustMailer.deliver_gift_expiry_reminder(self)
  end


  def send_gift_mail?
    return new_record? == false && !send_at? && !sent_at? && send_email? ? true : false
  end
  
  def expiry_date
    if !@expiry_date && sent_at
      @expiry_date = sent_at + 30.days
      beginning_of_2008 = '2008-01-01'.to_time
      @expiry_date = beginning_of_2008 if @expiry_date < beginning_of_2008
    end
    @expiry_date
  end
  
  def expiry_in_days
    ((expiry_date - Time.now) / (3600*24)).floor if expiry_date
  end
  
  def self.find_unopened_gifts
    find(:all, :conditions => 'sent_at IS NOT NULL AND pickup_code IS NOT NULL')
  end
  
  protected
  def validate_on_create
    require 'iats/credit_card'
    if credit_card? || !user_id?
      errors.add_on_empty %w( first_name last_name address city province postal_code country credit_card expiry_month expiry_year card_expiry )
      errors.add("credit_card", "has invalid format") unless CreditCard.is_valid(credit_card)
      errors.add("credit_card", "is an unknown card type") unless CreditCard.cc_type(credit_card) != 'UNKNOWN'
      errors.add("card_expiry", "is in the past") if card_expiry && card_expiry < Date.today
    end
    if user_id? && !credit_card?
      errors.add("amount", "cannot be greater than your balance. Please make a deposit first or use your credit card.") if amount? && amount > self.user.balance
    end
    errors.add("send_at", "must be in the future") if send_at? && send_at.to_i <= Time.now.to_i
    errors.add("amount", "cannot be more than the project's current need - #{number_to_currency(project.current_need)}") if amount && project_id && project && amount > project.current_need
    super
  end
  
  def before_validation
    self[:project_id] = nil if project_id == 0
    super
  end
  
  def validate
    errors.add("project_id", "is not a valid project") if project_id? && project_id <= 0
    super
  end

  def before_save
    self.credit_card = credit_card.to_s[-4, 4] if credit_card != nil
  end

  def make_pickup_code
    code = Gift.generate_pickup_code
    # ensure it's not currently being used
    if !Gift.find_by_pickup_code(code)
      self.pickup_code = code and return
    end
    # if we get here, it's being used, so try again
    make_pickup_code
  end
  
  def self.generate_pickup_code
    hash = ""
    srand()
    (1..12).each do
      rnd = (rand(2147483648)%36) # using 2 ** 31
      rnd = rnd<26 ? rnd+97 : rnd+22
      hash = hash + rnd.chr
    end
    hash
  end

  def trim_mailtos
    self[:to_email].sub!(/^ *mailto: */, '') if self[:to_email]
    self[:email].sub!(/^ *mailto: */, '') if self[:email]
  end
  
  def self.dollars_gifted
    raised = 0
    self.find(:all).each do |gift|
      raised = raised + gift.amount
    end
    raised
  end
  
   def self.dollars_redeemed
    raised = 0
    self.find(:all, :conditions => ["pickup_code is null"] ).each do |gift|
      raised = raised + gift.amount
    end
    raised
  end

  private
  def tax_receipt_create
    if credit_card? && country? && country.downcase == 'canada'
      @tax_receipt = TaxReceipt.new
      @tax_receipt.user = self.user if self.user
      @tax_receipt.gift_id = self.id
      @tax_receipt.email = self.email
      @tax_receipt.first_name = self.first_name
      @tax_receipt.last_name = self.last_name
      @tax_receipt.address = self.address
      @tax_receipt.city = self.city
      @tax_receipt.province = self.province
      @tax_receipt.postal_code = self.postal_code
      @tax_receipt.country = self.country
      @tax_receipt.save
    end
  end
end
