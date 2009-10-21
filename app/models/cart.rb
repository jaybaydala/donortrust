class Cart < ActiveRecord::Base
  attr_reader :total
  before_save :check_subscription
  has_many :items, :class_name => "CartLineItem" 
  
  def check_subscription
    if subscription? && subscription_changed?
      items.each do |line_item|
        line_item.destroy unless line_item.item_type == "Investment"
      end
    end
  end
  
  def empty!
    @items = []
    @total = 0.0
  end
  
  def empty?
    self.items.empty?
  end
  
  def add_item(item)
    logger.debug(valid_item?(item))
    logger.debug(item.inspect)
    if valid_item?(item)
      i = self.items.build({:item => item})
      i.item = item
      logger.debug(i.inspect)
      i.save!
    end
  end
  
  def update_item(id, item)
    self.items.find(id).update_attribute(:item, item) if valid_item?(item)
  end
  
  def empty?
    self.items.count == 0
  end
  
  def total
    @total ||= self.items.inject(0.0){|sum, line_item| sum + line_item.item.amount.to_f}
  end
  
  def remove_item(id)
    self.items.find(id).destroy
  end
  
  def minimum_credit_card_payment
    minimum = 0
    self.items.each do |line_item|
      minimum += line_item.item.amount if line_item.item.class == Deposit
    end
    minimum
  end
  
  def gifts
    self.items.select{|item| item.item_type == "Gift" }.map(&:item)
  end
  
  def investments
    self.items.select{|item| item.item_type == "Investment" }.map(&:item)
  end
  
  def deposits
    self.items.select{|item| item.item_type == "Deposit" }.map(&:item)
  end
  
  def pledges
    self.items.select{|item| item.item_type == "Pledge" }.map(&:item)
  end
  
  def registration_fees
    self.items.select{|item| item.item_type == "RegistrationFee" }.map(&:item)
  end
  
  private
  def valid_item?(item)
    [Gift, Investment, Deposit, Pledge, RegistrationFee].include?(item.class) && item.valid?
  end
end
