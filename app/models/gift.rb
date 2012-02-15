require 'digest/sha1'
class Gift < ActiveRecord::Base
  include UserTransactionHelper

  before_create :make_pickup_code
  before_create :set_balance
  before_create :set_project_id
  before_validation :send_now_if_requested

  belongs_to :user
  belongs_to :project
  belongs_to :e_card
  belongs_to :order
  belongs_to :promotion
  has_one :deposit
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_presence_of :to_email
  validates_presence_of :email
  validates_confirmation_of :to_email, :email, :on => :create
  validates_numericality_of :amount, :if => Proc.new { |gift| gift.amount? }
  validates_uniqueness_of :pickup_code, :allow_nil => true
  # validates_uniqueness_of :to_email, :scope => :order_id
  validates_numericality_of :project_id, :only_integer => true, :if => Proc.new { |gift| gift.project_id? }
  validate_on_create :send_at_in_future

  after_create :user_transaction_create, :tax_receipt_create, :create_project_pois


  attr_accessor :preview, :to_emails

  named_scope :sendable, lambda {
    { :conditions => ['send_email != ? AND send_email != ? AND (send_at <= ? OR send_at IS NULL) AND sent_at IS NULL', 'no', '0', Time.now.utc.to_s(:db)] }
  }
  named_scope :unopened, lambda {
    { :conditions => 'pickup_code IS NOT NULL and picked_up_at IS NULL' }
  }

  def sum
    return credit_card ? 0 : super * -1
  end

  def self.validate_pickup(pickup_code, id=nil)
    return nil if pickup_code.nil? || pickup_code.empty?
    gift = find_by_id_and_pickup_code(id, pickup_code, :conditions => { :picked_up_at => nil }) unless id.nil?
    gift = find_by_pickup_code(pickup_code, :conditions => { :picked_up_at => nil }) if id.nil?
    gift
  end

  def send_email?
    return false if send_email == 'no' || send_email == "0"
    true
  end

  def adjust_send_at_for_timezone(tz)
    
  end
  
  def pickup
    DonortrustMailer.deliver_gift_notify(self) if notify_giver?
    @picked_up = true if update_attributes(:picked_up_at => Time.now.utc, :pickup_code => nil)
  end
  
  def picked_up?
    @picked_up || !picked_up_at.nil?
  end
  
  def send_gift_mail
    if update_attribute(:sent_at, Time.now.utc)
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

  def send_gift_resend_sender
    DonortrustMailer.deliver_gift_resend_sender(self)
  end

  def send_gift_reminder
    DonortrustMailer.deliver_gift_expiry_notifier(self) if notify_giver?
    DonortrustMailer.deliver_gift_expiry_reminder(self)
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
    find(:all, :conditions => 'sent_at IS NOT NULL AND picked_up_at IS NULL')
  end
  
  # set the reader methods for the columns dealing with currency
  # we're using BigDecimal explicity for mathematical accuracy - it's better for currency
  def amount
    BigDecimal.new(read_attribute(:amount).to_s) unless read_attribute(:amount).nil?
  end
  def balance
    BigDecimal.new(read_attribute(:balance).to_s) unless read_attribute(:balance).nil?
  end
  
  
  def message_summary(length = 30) # default to 30 characters
    return unless self.message?
    if message.length <= length
      @message_summary = message
    else
      @message_summary = message.split($;, length+1)
      @message_summary.pop
      @message_summary = @message_summary.join(' ')
      @message_summary += (@message_summary[-1,1] == '.' ? '..' : '...')
    end
    @message_summary
  end
  
  def pdf
    GiftPDFProxy.new(self)
  end
  
  protected

  def set_project_id
    if self.sector_id && self.project_id.nil?
      sector = Sector.find(self.sector_id)
      project_ids = sector.projects.collect{|p| p.id if p.current_need > self.amount}
      self.project_id = project_ids[rand(project_ids.length)]
    end
  end

  def set_balance
    self.balance = amount if project_id.nil?
  end

  def before_validation
    self.project_id = nil unless project_id?
    self.number = number.gsub(/[^0-9]/, "") if attribute_present?("number")
    self.to_email = to_email.sub(/^ *mailto: */, '') if attribute_present?("to_email")
    self.email = email.sub(/^ *mailto: */, '') if attribute_present?("email")
    self.balance = nil if project_id?
    super
  end
  
  def validate
    errors.add("project_id", "is not a valid project") if project_id? && !project
    errors.add("to_email", "must be a valid email") unless EmailParser.parse_email(to_email) if attribute_present?("to_email")
    errors.add("email", "must be a valid email") unless EmailParser.parse_email(email) if attribute_present?("email")
    errors.add("amount", "cannot be more than the project's current need - #{number_to_currency(project.current_need)}") if amount && project_id? && project && amount > project.current_need
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

  def send_at_in_future
    if send_email? && send_at? && send_at <= Time.now
      errors.add("send_at", "must be in the future")
      false
    end
  end

  def send_now_if_requested
    write_attribute(:send_at, Time.now + 20.minutes) if self.send_email == "now"
  end

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

  def create_project_pois
    return unless project
    poi = project.project_pois.find_or_create_by_email(email)
    poi.attributes = { :email => email, :name => name, :gift_giver => true }
    poi.user ||= user # grab user if given
    poi.save!
    poi = project.project_pois.find_or_create_by_email(to_email)
    poi.attributes = { :email => to_email, :name => to_name, :gift_receiver => true }
    poi.save!
  end
end
