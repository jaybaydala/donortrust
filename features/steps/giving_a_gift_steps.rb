Then /^I should see 3 gifts in my cart$/ do
  response.should have_tag("#cart div.gift", :count => 3)
end

Then /^I should see all the email addresses from the file in "Gift Recipients" PENDING$/ do
end

Then /^I should get an error message with further instructions PENDING$/ do
end

