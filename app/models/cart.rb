class Cart < ActiveRecord::Base
  attr_reader :total
  before_save :check_subscription
  after_save :add_admin_project_investment
  has_many :items, :class_name => "CartLineItem"

  def add_donation(item, percentage=nil)
    if valid_item?(item)
      i = self.items.build({:item => item, :donation => true, :auto_calculate_amount => true})
      i.item = item
      i.percentage = percentage if percentage.present?
      i.save!
    end
  end

  def add_item(item)
    if valid_item?(item)
      i = self.items.build({:item => item})
      i.item = item
      i.save!
    end
  end

  def calculate_percentage_amount(percentage)
    BigDecimal.new(self.total_without_donation.to_s) * (BigDecimal.new(percentage.to_s)/100)
  end

  def check_subscription
    if subscription? && subscription_changed?
      items.each do |line_item|
        line_item.destroy unless line_item.item_type == "Investment"
      end
    end
  end

  def donation
    @donation ||= self.items.find_by_donation(true)
  end

  def deposits
    self.items.select{|item| item.item_type == "Deposit" }.map(&:item)
  end

  def empty!
    items.each do |line_item|
      line_item.destroy
    end
  end

  def empty?
    self.items.empty?
  end

  def gifts
    self.items.select{|item| item.item_type == "Gift" }.map(&:item)
  end

  def investments
    self.items.select{|item| item.item_type == "Investment" }.map(&:item)
  end

  def minimum_credit_card_payment
    minimum = 0
    self.items.each do |line_item|
      minimum += line_item.item.amount if line_item.item.class == Deposit
    end
    minimum
  end

  def percentage_options
    percentage_options = [20, 15, 10, 5, 0].map do |percentage|
      percentage_description = percentage == 0 ? "Not Now" : "#{percentage}%"
      [ "#{number_to_currency(calculate_percentage_amount(percentage))} (#{percentage_description})", percentage]
    end
    percentage_options.push(["Other amount - #{number_to_currency(self.donation.item.amount)}", ""])
  end

  def pledges
    self.items.select{|item| item.item_type == "Pledge" }.map(&:item)
  end

  def registration_fees
    self.items.select{|item| item.item_type == "RegistrationFee" }.map(&:item)
  end

  def remove_item(id)
    self.items.find(id).destroy
  end

  def total
    @total ||= self.items.inject(BigDecimal.new('0')){|sum, line_item| sum + BigDecimal.new(line_item.item.amount.to_s) }
  end

  def total_without_donation
    @total_without_donation ||= self.items.find_all_by_donation([false, nil]).inject(BigDecimal.new('0')){|sum, line_item| sum + BigDecimal.new(line_item.item.amount.to_s) }
  end

  def update_item(id, item)
    self.items.find(id).update_attribute(:item, item) if valid_item?(item)
  end

  private
    def add_admin_project_investment
      if Project.admin_project && self.items.find_by_auto_calculate_amount(true).nil?
        self.add_donation( Investment.new(:project => Project.admin_project, :amount => 1) )
      end
    end

    def valid_item?(item)
      [Gift, Investment, Deposit, Pledge, RegistrationFee].include?(item.class) && item.valid?
    end
end
