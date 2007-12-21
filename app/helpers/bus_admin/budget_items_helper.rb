module BusAdmin::BudgetItemsHelper
  
  def cost_column(record)
    number_to_currency(record.cost)
  end
  
end
