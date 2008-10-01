# USER HELPERS
# ================================
def login
  @user = User.generate!
  @user.activate
  post("/dt/session", {:login => @user.login, :password => @user.password})
end

# GIFT HELPERS
# ================================
def open_gift(pickup_code)
  get("/dt/gifts/open?code=#{pickup_code}")
end

# CART HELPERS
# ================================

def add_gift_to_cart(amount, project_id=nil)
  visits "/dt/gifts/new"
  fills_in("Gift Amount", :with => amount)
  fills_in("gift_email", :with => "test1@example.com")
  fills_in("gift_email_confirmation", :with => "test1@example.com")
  fills_in("gift_to_email", :with => "test2@example.com")
  fills_in("gift_to_email_confirmation", :with => "test2@example.com")
  chooses("gift_project_id_#{project_id}") unless project_id.nil?
  clicks_button("Add to Cart")
end
def add_investment_to_cart(amount, project_id=nil)
  url = "/dt/investments/new"
  url += "?project_id=#{project_id}" unless project_id.nil?
  visits url
  fills_in("investment_amount", :with => amount)
  chooses("investment_project_id_#{project_id}") unless project_id.nil?
  clicks_button("Add to Cart")
end
def add_deposit_to_cart(amount, project_id=nil)
  login
  visits "/dt/accounts/#{@user.id}/deposits/new"
  fills_in("deposit_amount", :with => amount)
  clicks_button("Add to Cart")
end

# CHECKOUT HELPERS
# ================================
def checkout_steps 
  %w( support billing payment confirmation )
end
def checkout_support_step(type=false, amount=nil)
  Project.generate!({ :slug => "admin" }) unless Project.admin_project
  visits "/dt/checkout/new"
  case type
  when false
    chooses("fund_cf_no")
  when "percent"
    chooses("fund_cf_percent")
    fills_in("fund_cf_amount", :with => amount)
  when "dollars"
    chooses("fund_cf_dollars")
    fills_in("fund_cf_amount", :with => amount)
  end
  clicks_button("Proceed to Step 2")
end
def checkout_billing_step(params={})
  fills_in("order_first_name", :with => params[:first_name] || "Test")
  fills_in("order_last_name", :with => params[:last_name] || "Name")
  fills_in("order_address", :with => params[:address] || "123 Hithere St.")
  fills_in("order_city", :with => params[:city] || "Calgary")
  fills_in("order_province", :with => params[:province] || "AB")
  fills_in("order_postal_code", :with => params[:postal_code] || "T2Y 3N2")
  selects(params[:country] || "Canada", :from => "order_country") 
  fills_in("order_email", :with => params[:email] || "test@example.com")
  clicks_button("Proceed to Step 3")
end
def checkout_payment_step(params={})
  fills_in("order_card_number", :with => params[:card_number] || "1")
  fills_in("order_cardholder_name", :with => params[:cardholder_name] || "Test User")
  fills_in("order_cvv", :with => params[:cvv] || "989")
  selects(params[:expiry_month] || "04", :from => "order_expiry_month") 
  selects(params[:expiry_year] || Time.now.year+1, :from => "order_expiry_year") 
  clicks_button("Proceed to Step 4")
end
def checkout_confirmation_step
  clicks_button("Complete Checkout")
end
