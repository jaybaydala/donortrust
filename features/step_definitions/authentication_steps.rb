When /^I authenticate with (.*)$/ do |provider|
  # noop
end

When /^I allow donortrust access to my facebook account$/ do
  visit dt_auth_callback_path(:facebook)
end

Then /^I should see "([^"]*)" within the listed authentications$/ do |provider_name|
  Then "I should see \"#{provider_name}\" within \".authentications .authentication .provider\""
end
