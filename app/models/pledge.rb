class Pledge < ActiveRecord::Base
  include UserTransactionHelper

  belongs_to :participant
  belongs_to :team
  belongs_to :campaign
  belongs_to :user

  has_one :user_transaction, :as => :tx

  validates_presence_of :amount
  validates_numericality_of :amount

  after_create :user_transaction_create
end
