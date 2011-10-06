class CartLineItem < ActiveRecord::Base
  belongs_to :cart
  validates_presence_of :cart_id, :item
  serialize :item_attributes
  before_save :set_amount_for_auto_tip
  after_save :update_auto_tip
  
  attr_accessor :item, :amount
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

  def amount=(val)
    item = self.item
    item.amount = val
    self.item = item
  end

  def amount
    item.amount
  end

  def percentage
    val = read_attribute(:percentage)
    if self.auto_calculate_amount?
      val
    else
      ""
    end
  end

  private
    def set_amount_for_auto_tip
      if self.auto_calculate_amount? && self.item.present?
        cart = Cart.find(cart_id)
        self.item_attributes["amount"] = cart.calculate_percentage_amount(self.percentage)
      end
    end

    def update_auto_tip
      auto_tip = self.class.find_by_cart_id_and_auto_calculate_amount(self.cart_id, true)
      if auto_tip && auto_tip != self
        # just touch the record to trigger the before_save on it
        auto_tip.touch
      end
    end
end
