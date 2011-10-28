class Tip < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :group
  belongs_to :gift
  belongs_to :order
  belongs_to :promotion
  belongs_to :campaign
  has_one :user_transaction, :as => :tx

  def name
    if self.user.present?
      self.user.name
    elsif self.order.present?
      self.order.name
    end
  end
end
