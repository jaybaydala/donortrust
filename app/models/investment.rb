class Investment < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :user
  belongs_to :project
  belongs_to :group
  belongs_to :gift
  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  validates_numericality_of :project_id, :only_integer => true
  validates_presence_of :project_id
  
  def sum
    #return 0 if self[:gift_id] && self.gift[:project_id]
    super * -1
  end

  def self.new_from_gift(gift, user_id)
    logger.info "Gift: #{gift.inspect}"
    if gift.project_id
      i = Investment.new( :amount => gift.amount, :user_id => user_id, :project_id => gift.project_id, :gift_id => gift.id )
    end
  end

  def validate
    super
    errors.add("project_id", "is not a valid project") if project_id && project_id <= 0
    errors.add("user_id", "is not a valid project") if user_id && user_id <= 0
    errors.add("amount", "cannot be more than your balance") if user_id && user && !gift_id && amount && amount > user.balance
  end
end
