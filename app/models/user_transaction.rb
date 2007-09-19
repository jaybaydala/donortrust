class UserTransaction < ActiveRecord::Base
  belongs_to :user
  belongs_to :tx, :polymorphic => true

  validates_presence_of :user_id
  validates_presence_of :tx
end
