Given /^I have authenticated with (.*)/ do |provider|
  visit dt_auth_callback_path(provider.to_sym)
end

When /^I authenticate with (.*)$/ do |provider|
  visit dt_auth_callback_path(provider.to_sym)
end

Given /^I have allowed access to my (.*) account$/ do |provider|
  visit dt_auth_callback_path(provider.to_sym)
end

Then /^I should see "([^"]*)" within the listed authentications$/ do |provider_name|
  Then "I should see \"#{provider_name}\" within \".authentications .authentication .provider\""
end
