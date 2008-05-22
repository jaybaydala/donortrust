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

  def cf_investment
    cf_investment = nil
    if Project.cf_admin_project
      cf_investment = @items.detect{|item| item.is_a?(Investment) and item.project_id? and item.project_id == Project.cf_admin_project.id }
    end
    cf_investment
  end
  
  def cf_investment_index
    @items.index(cf_investment) if cf_investment
  end
  
  private
  def valid_item?(item)
    [Gift, Investment, Deposit].include?(item.class) && item.valid?
  end
end
