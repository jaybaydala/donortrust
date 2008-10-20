Then /^I should see 3 gifts in my cart$/ do
puts response.body
  response.should have_tag("#cart div.gift", :count => 3)
end

When /^I upload a valid file to Import$/ do
end

Then /^I should see all the email addresses from the file in "Gift Recipients"$/ do
end

When /^I upload an invalid file to Import$/ do
end

Then /^I should get an error message with further instructions$/ do
end

