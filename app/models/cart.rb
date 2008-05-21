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
    @items << item if [Gift, Investment, Deposit].include?(item.class) && item.valid?
  end

	def empty?
    @items.length == 0
	end
	
	def total
	  @total = @items.inject(0.0){|sum, item| sum + item.amount}
  end

  def remove_item(index)
    @items.delete_at(index) if @items[index]
  end
end
