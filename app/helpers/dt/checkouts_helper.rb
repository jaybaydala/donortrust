module Dt::CheckoutsHelper
  def titles
    %w(Mr. Mrs. Ms. Miss Dr. Rev.)
  end
  
  def checkout_nav
    render :file => "dt/checkouts/checkout_nav"
  end
  
  def cart_org_investment
    return nil unless @cart && Project.admin_project
    @cart_org_investment ||= @cart.items.detect{|item| item.class == Investment && item.project_id == Project.admin_project.id && item.checkout_investment? }
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
  
  def pledge_account
    return unless logged_in?
    PledgeAccount.find(:first, :conditions => {:user_id => current_user})
  end
end
