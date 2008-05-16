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
    @items << item if [Gift, Investment, Deposit].include?(item.class)
  end

	def empty?
    @items.length == 0
	end
	
	def total
	  @total = @items.inject(0.0){|sum, item| sum + item.amount}
  end

  # Returns the total price of our cart
  # def total
  #   @total = 0.0
  #   for item in @items
  #     @total += (item.quantity * item.unit_price)
  #   end
  #   return @total
  # end
  # Defined here because in order we have a line_items_total
  # That number is the total of items - shipping costs.
  # def line_items_total
  #   total
  # end

  # Adds a product to our shopping cart
  # def add_product(product, quantity=1)
  #   item = @items.find { |i| i.product_id == product.id }
  #   if item
  #     item.quantity += quantity
  #     # Always set price, as it might have changed...
  #     item.price = product.price
  #   else
	# 		item = OrderLineItem.for_product(product)
	# 		item.quantity = quantity
  #     @items << item
  #   end
  # end

	# Removes all quantities of product from our cart
	# def remove_product(product, quantity=nil)
	# 	item = @items.find { |i| i.product_id == product.id }
	#   if quantity.nil?
	#     quantity = item.quantity
	#   end
	# 	if item
  #     if item.quantity > quantity then
  #       item.quantity -= quantity
  #     else
  #       @items.delete(item)
	# 		end
	# 	end
	# end
	
	# Checks inventory of products, and removes them if
	# they're out of stock.
	#
	# Returns an array of items that have been removed.
	#
	# def check_inventory
	#   removed_items = []
	#   for oli in @items do
	#     # Find the item in the db, because oli.item
	#     # is cached.
	#     db_item = Item.find(oli.item_id)
	#     
	#     if oli.quantity > db_item.quantity
	#       removed_items << oli.name.clone
	#       @items.delete(oli)
  #     end
  #   end
  #   return removed_items
  # end

end
