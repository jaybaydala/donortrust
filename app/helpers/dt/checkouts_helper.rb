module Dt::CheckoutsHelper
  def titles
    %w(Mr. Mrs. Ms. Miss Dr. Rev.)
  end
  
  def checkout_nav
    render "dt/checkouts/checkout_nav"
  end
end
