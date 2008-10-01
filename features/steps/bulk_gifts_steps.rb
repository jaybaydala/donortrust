Given /^I am any user$/ do
end

Then /I  will see a link to the "Return to Individual Gift Giving" page/ do
  response.should have_tag("a[href=/dt/gifts/new]", "Return to Individual Gift Giving")
end

Given /that I am on the bulk gift giving page/ do
  visits "/dt/bulk_gifts/new"
end

Then /I should see 3 gifts in my cart/ do
  visits "/dt/cart"
  response.should have_tag("#cart p")
end
