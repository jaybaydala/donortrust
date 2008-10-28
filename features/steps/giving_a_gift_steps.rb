Then /^I should see (\d+) gifts in my cart$/ do |count|
  response.should have_tag("#cart div.gift", :count => count.to_i)
end

Then /^I should see all the email addresses from the file in "Gift Recipients" PENDING$/ do
end

Then /^I should get an error message with further instructions PENDING$/ do
end

