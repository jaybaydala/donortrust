class Cart
  attr_reader :items, :total
  
  def initialize
    empty!
  end
  
  def empty!
    @items = []
    @total = 0.0
  end

  def empty?
    @items.empty?
  end
  
  def add_item(item)
    @items << item if valid_item?(item)
  end

  def update_item(index, item)
    @items[index.to_i] = item if valid_item?(item)
  end

	def empty?
    @items.length == 0
	end
	
	def total
	  @total = @items.inject(0.0){|sum, item| sum + item.amount.to_f}
  end

  def remove_item(index)
    @items.delete_at(index.to_i) if @items[index.to_i]
  end
  
  def minimum_credit_card_payment
    minimum = 0
    @items.each do |item|
      minimum += item.amount if item.class == Deposit
    end
    minimum
  end
  
  def gifts
    @items.select{|item| item.is_a?(Gift) }
  end
  
  def investments
    @items.select{|item| item.is_a?(Investment) }
  end
  
  def deposits
    @items.select{|item| item.is_a?(Deposit) }
  end

  def pledges
    @items.select{|item| item.is_a?(Pledge)}
  end

  def registration_fees
    @items.select{|item| item.is_a?(RegistrationFee)}
  end

  private
  def valid_item?(item)
    [Gift, Investment, Deposit, Pledge, RegistrationFee].include?(item.class) && item.valid?
  end
end
