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


When /^I checkout$/ do
  checkout_steps.each do |step|
    send("checkout_#{step}_step")
  end
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