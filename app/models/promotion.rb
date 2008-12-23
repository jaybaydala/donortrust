class Promotion < ActiveRecord::Base

  def get_raised(promotion_id)
    return get_value_of_gifts(promotion_id) + get_value_of_investments(promotion_id)
  end

  def get_value_of_gifts(promotion_id)
    gifts = get_gifts_for_promotion(promotion_id)
    return get_total_value(gifts)
  end

  def get_value_of_investments(promotion_id)
    investments = get_investments_for_promotion(promotion_id)
    return get_total_value(investments)
  end

  def get_number_of_gifts(promotion_id)
    gifts = get_gifts_for_promotion(promotion_id)
    return gifts.length
  end

  def get_number_of_investments(promotion_id)
    investments = get_investments_for_promotion(promotion_id)
    return investments.length
  end

  private
  def get_investments_for_promotion(promotion_id)
    investments = Investment.find(:all, :conditions => ['promotion_id = ?', promotion_id])
  end

  private
  def get_gifts_for_promotion(promotion_id)
    gifts = Gift.find(:all, :conditions => ['promotion_id = ?', promotion_id])
  end

  private
  def get_total_value(transactions)
    total_raised = 0
    transactions.each do |transaction|
      if transaction.amount != nil
         total_raised += transaction.amount
      end
    end
    return total_raised
  end
end
