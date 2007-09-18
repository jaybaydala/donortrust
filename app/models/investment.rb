class Investment < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  belongs_to :project
  belongs_to :group
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  validates_numericality_of :project_id, :only_integer => true
  has_one :user_transaction, :as => :tx
  validates_presence_of :project_id
  
  def sum
    super * -1
  end

  def self.create_from_gift(gift, user_id)
    if gift.project_id
      Investment.create( :amount => gift.amount, :user_id => user_id, :project_id => gift.project_id, :gift_id => gift.id )
    end
  end

  def validate
    super
    errors.add("project_id", "is not a valid project") if project_id && project_id <= 0
    errors.add("user_id", "is not a valid project") if user_id && user_id <= 0
    errors.add("amount", "cannot be more than your balance") if user_id && user && amount && amount > user.balance
  end
end
