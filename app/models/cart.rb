class Cart
  attr_reader :items, :total
  
  def initialize(add_cf=false)
    @add_cf = add_cf
  end
  
  def items
    @items = [
      Gift.new({"name"=>"Jay Baydala", "message"=>"This is cool", "project_id"=>5, "to_name"=>"Tim Glen", "pickup_code"=>"123456", "to_email"=>"timglen@pivotib.com", "amount"=>50, "send_email"=>true, "e_card_id"=>8, "email"=>"tim@pivotib.com"}), 
      Investment.new(:project_id => 5, :amount => 25),
      Deposit.new(:amount => 25)
    ]
    @items << Investment.new(:project_id => 10, :amount => 25) if @add_cf
    @items
  end
  
  def total
    return 125 if @add_cf
    100
  end
  
  def empty?
    false
  end
  

  # Initializes the shopping cart
  # def initialize
  #   empty!
  # end
  
  # Empties or initializes the cart
  # def empty!
  #   @items = []
  #   @tax = 0.0
  #   @total = 0.0
  #   @shipping_cost = 0.0
  # end

	# def empty?
	# 	@items.length == 0
	# end

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
