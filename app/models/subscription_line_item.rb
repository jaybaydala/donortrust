class SubscriptionLineItem < ActiveRecord::Base
  belongs_to :subscription
  validates_presence_of :subscription_id, :item
  serialize :item_attributes
  
  attr_accessor :item
  def item
    if self.item_type? && self.item_attributes?
      @item ||= self.item_type.constantize.new(self.item_attributes)
    end
  end
  
  def item=(val)
    if val.valid?
      self.item_type = val.class.to_s
      self.item_attributes = val.attributes
    end
  end
end