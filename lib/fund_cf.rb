module FundCf
  protected
  def build_fund_cf_deposit(other)
    if params[:fund_cf] && params[:fund_cf_percentage] && other.credit_card? && cf_admin_project = Project.cf_admin_project
      cf_amount = other.amount * trim_percentage(params[:fund_cf_percentage])
      cf_deposit = Deposit.new
      other.attributes.each do |k,v|
        cf_deposit[k] = v if cf_deposit.attribute_names.include?(k)
      end
      cf_deposit.expiry_month = other.expiry_month if other.expiry_month
      cf_deposit.expiry_year = other.expiry_year if other.expiry_year
      cf_deposit.card_expiry = other.card_expiry if other.card_expiry
      cf_deposit.amount = cf_amount
    end
    cf_deposit
  end

  def build_fund_cf_investment(other)
    if params[:fund_cf] && params[:fund_cf_percentage] && cf_admin_project = Project.cf_admin_project
      cf_amount = other.amount * trim_percentage(params[:fund_cf_percentage])
      cf_investment = Investment.new
      other.attributes.each do |k,v|
        cf_investment[k] = v if cf_investment.attribute_names.include?(k)
      end
      cf_investment.amount = cf_amount
      cf_investment.project_id = cf_admin_project.id
    end
    cf_investment
  end

  def cf_fund_investment_valid?(other, cf_investment)
    if cf_investment
      cf_investment.credit_card_tx = other.attribute_names.include?('credit_card') && other.credit_card?
      other.amount += cf_investment.amount if cf_investment.credit_card_tx? # temporarily add the entire amount to the original investment - this will test the account balance
      valid = other.valid? && cf_investment.valid?
      other.amount -= cf_investment.amount if cf_investment.credit_card_tx? # subtract the overhead again
    else 
      valid = other.valid?
    end
    valid
  end
  
  def trim_percentage(percentage)
    percentage = percentage.strip
    percentage = percentage.sub(/%$/, "") if percentage.match(/%$/)
    percentage.to_f / 100
  end
end