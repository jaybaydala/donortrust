Then /^I should see (\d+) gifts in my cart$/ do |count|
  response.should have_tag("#cart div.gift", :count => count.to_i)
end

Then /^I should see all the email addresses from the file in "Gift Recipients" PENDING$/ do
end

Then /^I should get an error message with further instructions PENDING$/ do
end

When /^I attach the \"([^\"]+)\" file to \"([^\"]+)\"/ do |file, field|
  path = File.join(RAILS_ROOT, "spec", "fixtures", "email_uploads", file)
system("mate #{path}")
  attaches_file(field, path)
end