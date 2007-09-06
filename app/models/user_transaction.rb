class UserTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :tx, :polymorphic => true
  validates_presence_of :user_id
  validates_presence_of :tx

  def self.balance(user_id)
    user_transactions = UserTransaction.find(:all, :conditions => { :user_id => user_id })
    balance = 0
    user_transactions.each do |trans|
      balance += trans.tx.sum if trans.tx
    end
    balance
  end
end
