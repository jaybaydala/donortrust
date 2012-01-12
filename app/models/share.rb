class Share < ActiveRecord::Base
  belongs_to :project
  belongs_to :e_card
  belongs_to :user
  validates_presence_of :to_email, :email
  validates_confirmation_of :to_email, :email, :on => :create
  validates_format_of   :to_email,    :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.to_email?}
  validates_format_of   :email,       :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address", :if => Proc.new { |gift| gift.email?}
  validates_numericality_of :project_id, :only_integer => true, :if => Proc.new { |share| share.project_id? && share.project_id != 0 }
  before_validation :trim_mailtos
  after_create :send_share_mail
  attr_accessor :to_emails
  
  def send_share_mail
    if update_attributes(:sent_at => Time.now.utc)
      DonortrustMailer.deliver_share_mail(self)
      @sent = true
    end
  end
  
  protected
  def before_validation
    self[:project_id] = nil if self[:project_id] == 0
  end
  
  def validate
    errors.add("project_id", "is not a valid project") if project_id? && project_id <= 0
    super
  end
  
  protected
  def trim_mailtos
    self[:to_email].sub!(/^ *mailto: */, '') if self[:to_email]
    self[:email].sub!(/^ *mailto: */, '') if self[:email]
  end
end
