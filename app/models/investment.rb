class Investment < ActiveRecord::Base
  include UserTransactionHelper
  belongs_to :user
  belongs_to :project
  belongs_to :group
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_presence_of :user_id
  has_one :user_transaction, :as => :tx
  validates_presence_of :project_id
  
  def sum
    super * -1
  end
end
