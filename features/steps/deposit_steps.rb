Given /^I am on the new deposit page$/ do
  visits "/dt/accounts/1/deposits/new"
end

Given /^my cart has a deposit of \$(\d+\.?\d*)$/ do |amount|
  add_deposit_to_cart(amount)
end
