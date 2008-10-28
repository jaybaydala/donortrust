Before do
  place_type = PlaceType.generate!(:name => "Country") unless PlaceType.find_by_name("Country")
  ["Canada", "United States", "Gabon"].each do |country|
    Place.generate!({:name => country, :place_type_id => place_type.id}) unless Place.find_by_name(country)
  end
end

Given /^I add a gift for \$([\d]+[\.]?[\d]?) to my cart$/ do |amount|
  add_gift_to_cart(amount)
end
Given /^I add an investment for \$([\d]+[\.]?[\d]?) to my cart$/ do |amount|
  @project = Project.generate!
  add_investment_to_cart(amount, @project.id)
end


When /^I checkout using my credit card$/ do
  credit_card_payment = session[:cart].total
  checkout_support_step
  checkout_payment_step({:credit_card_payment => credit_card_payment})
  checkout_billing_step({:credit_card_payment => credit_card_payment})
  checkout_confirmation_step
end

When /^I checkout using my gift card$/ do
  gift_card_payment = session[:cart].total
  checkout_support_step
  checkout_payment_step({:gift_card_payment => gift_card_payment})
  checkout_billing_step
  checkout_confirmation_step
end

Given /^I have received a gift for \$([\d]+[\.]?[\d]?)$/ do |amount|
  @gift = Gift.generate!(:amount => amount)
end

Then /^the gift card amount should be \$([\d]+[\.]?[\d]?)$/ do |amount|
  Gift.find(:last).amount.should == amount.to_f
end
Then /^the gift card balance should be \$([\d]+[\.]?[\d]?)$/ do |balance|
  Gift.find(:last).balance.should == balance.to_f
end

Given /^I come back in another browser session$/ do
end

When /^I open my gift card again$/ do
  open_gift(@gift.pickup_code)
end

Then /^I should be told the gift card expiry date$/ do
  response.should have_tag(".notice", "Please note: Your gift card balance will expire on #{@gift.expiry_date.strftime("%b %e, %Y")}. If you need more time, please Deposit the balance into your account.")
end
