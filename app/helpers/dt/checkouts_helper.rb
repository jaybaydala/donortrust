module Dt::CheckoutsHelper
  def titles
    %w(Mr. Mrs. Ms. Miss Dr. Rev.)
  end
  
  def checkout_nav
    render "dt/checkouts/checkout_nav"
  end
  
  def cart_cf_investment
    return nil unless @cart && Project.admin_project
    @cart_cf_investment ||= @cart.items.find{|item| item.class == Investment && item.project_id == Project.admin_project.id }
  end
  
  def account_payment?
    logged_in? and current_user.balance > 0
  end
  
  def gift_card_payment?
    session[:gift_card_balance] && session[:gift_card_balance] > 0
  end
  
  def expiry_months
    (1..12).to_a.collect do |m|
      mo = m.to_s.rjust(2, "0")
      [ mo, m ]
    end
  end
  
  def expiry_years
    (0..7).to_a.collect do |y|
      d = Date.civil(Date.today.year+y.to_i)
      [ d.year, d.year ]
    end
  end
end
