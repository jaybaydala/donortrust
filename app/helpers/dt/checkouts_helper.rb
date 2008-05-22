module Dt::CheckoutsHelper
  def titles
    %w(Mr. Mrs. Ms. Miss Dr. Rev.)
  end
  
  def checkout_nav
    render "dt/checkouts/checkout_nav"
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
