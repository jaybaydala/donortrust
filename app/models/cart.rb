class Cart < ActiveRecord::Base
  after_save :add_auto_tip
  has_many :items, :class_name => "CartLineItem"
  has_one :order

  def add_tip(item, percentage=nil)
    if valid_item?(item)
      i = self.items.build({:item => item, :donation => true, :auto_calculate_amount => true})
      i.item = item
      i.percentage = percentage if percentage.present?
      i.save!
    end
  end

  def add_item(item)
    if valid_item?(item)
      line_item = self.items.build({:item => item})
      line_item.item = item
      line_item.save!
      line_item
    end
  end

  def add_upowered(amount, user)
    if self.subscription?
      cart_item = self.subscription
      if amount.present?
        cart_item.amount = amount
        cart_item.subscription = true
        cart_item.save
      else
        cart_item.destroy
      end
    else
      investment = Investment.new( :amount => amount )
      investment.project = Project.admin_project
      investment.user = user
      cart_item = self.add_item(investment)
      cart_item.update_attribute(:subscription, true) if cart_item
    end
    cart_item
  end

  def calculate_percentage_amount(percentage)
    total_to_calculate = BigDecimal.new(self.total_without_donation.to_s)
    total_to_calculate = total_to_calculate - subscription.item.amount if subscription?
    total_to_calculate * (BigDecimal.new(percentage.to_s)/100)
  end

  def donation
    @donation ||= self.items.find_by_donation(true)
  end

  def deposits
    self.items.all.select{|item| item.item_type == "Deposit" }.map(&:item)
  end

  def empty!
    items.each do |line_item|
      line_item.destroy
    end
  end

  def empty?
    self.items_without_donation.empty?
  end

  def campaign_donations
    self.items.select{|item| item.item_type == "CampaignDonation"}.map(&:item)
  end

  def gifts
    self.items.all.select{|item| item.item_type == "Gift" }.map(&:item)
  end

  def investments
    self.items.all.select{|item| item.item_type == "Investment" }.map(&:item)
  end
  
  def tips
    self.items.all.select{|item| item.item_type == "Tip" }.map(&:item)
  end

  def items_without_donation
    self.items.find_all_by_donation([false, nil])
  end

  def minimum_credit_card_payment
    minimum = 0
    self.items.all.each do |line_item|
      minimum += line_item.item.amount if line_item.item.class == Deposit
    end
    minimum
  end

  def only_subscription?
    self.items.all.delete_if(&:subscription?).delete_if{|i| i.item_type == "Tip" }.size == 0
  end

  def percentage_options
    percentage_options = [20, 15, 10, 5, 0].map do |percentage|
      percentage_description = percentage == 0 ? "Not Now" : "#{percentage}%"
      [ "#{number_to_currency(calculate_percentage_amount(percentage))} (#{percentage_description})", percentage]
    end
    percentage_options.push(["Other amount (#{number_to_currency(self.donation.item.amount)})", ""])
  end

  def pledges
    self.items.all.select{|item| item.item_type == "Pledge" }.map(&:item)
  end

  def registration_fees
    self.items.all.select{|item| item.item_type == "RegistrationFee" }.map(&:item)
  end

  def remove_item(id)
    self.items.find(id).destroy
  end

  def subscription?
    items.any?{|item| item.subscription? }
  end

  def subscription
    items.detect{|item| item.subscription? }
  end

  def has_tip?
    !self.items.find_by_item_type('Tip').nil?
  end

  def tip_item
    self.items.find_by_item_type('Tip')
  end

  def has_gift_card?
    !self.items.find_by_item_type('Gift').nil?
  end

  def gift_card_purchase_amount
    total = 0
    self.items.find_all_by_item_type('Gift').each do |gc|
      total += gc.amount
    end
    total
  end

  def total
    self.items.all.inject(BigDecimal.new('0')){|sum, line_item| sum + BigDecimal.new(line_item.item.amount.to_s) }
  end

  def total_without_donation
    items_without_donation.inject(BigDecimal.new('0')){|sum, line_item| sum + BigDecimal.new(line_item.item.amount.to_s) }
  end

  def update_item(id, item)
    self.items.find(id).update_attribute(:item, item) if valid_item?(item)
  end

  def update_order_total
    if self.order
      self.order.update_attribute(:total, self.total)
    end
  end

  private
    def add_auto_tip
      if add_optional_donation.blank?
        self.donation.destroy if self.donation.present?
      elsif add_optional_donation?
        if Project.admin_project && self.items.find_by_item_type('Tip').nil?
          self.add_tip( Tip.new(:project => Project.admin_project, :amount => 1) )
        end
      end
    end

    def valid_item?(item)
      [CampaignDonation, Gift, Investment, Deposit, Pledge, RegistrationFee, Tip].include?(item.class) && item.valid?
    end

end
