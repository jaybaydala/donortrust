class Cart
  attr_reader :items, :total
  
  def initialize
    empty!
  end
  
  def empty!
    @items = []
    @total = 0.0
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
	  @total = @items.inject(0.0){|sum, item| sum + item.amount}
  end

  def remove_item(index)
    @items.delete_at(index.to_i) if @items[index.to_i]
  end
  
  private
  def valid_item?(item)
    [Gift, Investment, Deposit].include?(item.class) && item.valid?
  end
end
