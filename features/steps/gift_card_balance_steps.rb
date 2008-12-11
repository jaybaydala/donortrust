Before do
  place_type = PlaceType.generate!(:name => "Country") unless PlaceType.find_by_name("Country")
  ["Canada", "United States", "Gabon"].each do |country|
    Place.generate!({:name => country, :place_type_id => place_type.id}) unless Place.find_by_name(country)
  end
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

Given /^I come back in another browser session$/ do
end
