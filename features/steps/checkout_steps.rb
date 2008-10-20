Before do
  place_type = PlaceType.find_by_name("Country") || PlaceType.generate!(:name => "Country")
  ["Canada", "United States", "Gabon"].each do |country|
    Place.generate!({:name => country, :place_type_id => place_type.id}) unless Place.find_by_name(country)
  end
end

Given /^I am starting the checkout process$/ do
  Project.generate!({ :slug => "admin" }) unless Project.find_by_slug("admin")
  visits "/dt/checkout/new"
end

Given /^my cart has (\d+) \$(\d+\.?\d*) gifts in it$/ do |number, amount|
  number.to_i.times do |n|
    add_gift_to_cart(amount)
  end
end

Given /^my cart has an investment of \$(\d+\.?\d*)$/ do |amount|
  add_investment_to_cart(amount)
end

Given /^my cart has a deposit of \$(\d+\.?\d*)$/ do |amount|
  add_deposit_to_cart(amount)
end

Then /^I should be on the billing step of the checkout process$/ do
  response.should have_tag("h2", "Step 2 of 4 - Billing Information")
end
Then /^I should be on the payment step of the checkout process$/ do
  response.should have_tag("h2", "Step 3 of 4 - Payment Details")
end
Then /^I should be on the confirmation step of the checkout process$/ do
  
  response.should have_tag("h2", "Step 4 of 4 - Confirmation")
end
Then /^I should be shown my order$/ do
  @order = Order.find_by_order_number(request.parameters[:order_number])
  response.should have_tag('h2', "Tax Receipt")
  response.should have_tag('h2', "Gift(s)")
  response.should have_tag("p", "Thanks! With your generous gift(s) of #{number_to_currency(@order.total)}, we're one step closer to changing the world...for good.")
end
