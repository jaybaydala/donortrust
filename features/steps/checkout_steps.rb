Given /I am on the first checkout page/ do
  visits "/dt/checkout/new"
end

Given /my cart has (\d+) gifts in it/ do |n|
  @cart = Cart.new
  n.to_i.times do |n|
    gift = Gift.new(:amount => (rand(25)*100).round/100.0, :email => "testfrom#{n}@example.com", :email_confirmation => "testfrom#{n}@example.com", :to_email => "testto#{n}@example.com", :to_email_confirmation => "testto#{n}@example.com")
    @cart.add_item(gift)
  end
end

Given /my cart has an investment/ do
  investment = Investment.new(:amount => 25, :project_id => 100)
  @cart = Cart.new
  @cart.add_item(investment)
end

Given /my cart has a deposit/ do
  deposit = Deposit.new(:amount => 20)
  @cart = Cart.new
  @cart.add_item(deposit)
end
