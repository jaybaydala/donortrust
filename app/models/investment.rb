class Investment < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :user
  belongs_to :project
  belongs_to :group
  belongs_to :gift
  belongs_to :order
  belongs_to :promotion
  belongs_to :campaign
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_numericality_of :project_id, :only_integer => true
  validates_presence_of :project_id

  after_create :user_transaction_create
  after_create :update_project
  
  def self.dollars_raised(conditions = {})
    self.find(:all, :conditions => conditions).inject(0){|raised, investment| raised += investment.amount }
  end
  

  def sum
    #return 0 if self[:gift_id] && self.gift[:project_id]
    super * -1
  end

  # set the reader methods for the columns dealing with currency
  # we're using BigDecimal explicity for mathematical accuracy - it's better for currency
  def amount
    BigDecimal.new(read_attribute(:amount).to_s) unless read_attribute(:amount).nil?
  end
  
  def self.new_from_gift(gift, user_id)
    logger.info "Gift: #{gift.inspect}"
    if gift.project_id
      i = Investment.new( :amount => gift.amount, :user_id => user_id, :project_id => gift.project_id, :gift_id => gift.id )
    end
  end
  
  def credit_card_tx?
    @credit_card_tx
  end
  def credit_card_tx
    credit_card_tx?
  end
  def credit_card_tx=(val)
    @credit_card_tx ||= val ? true : false
  end

  # this is for the "special" checkout investment option to support the admin project directly
  def checkout_investment?
    @checkout_investment || false
  end
  def checkout_investment=(val)
    @checkout_investment = val ? true : false
  end
  alias_method :checkout_investment, :checkout_investment?

  def name
    if self.user.present?
      self.user.name
    elsif self.order.present?
      self.order.name
    end
  end

  protected

  def update_project
    self.project.touch
  end

  def validate
    super
    errors.add("project_id", "is not a valid project") if project_id && project_id <= 0
    errors.add("amount", "cannot be more than the project's current need - #{number_to_currency(project.current_need)}") if amount && project && amount > project.current_need
  end

end
