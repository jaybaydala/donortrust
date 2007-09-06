class Gift < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  has_one :user_transaction, :as => :tx
  validates_presence_of :to_user_id

  def sum
    amount * -1
  end
end
