Given /^a campaign with short name "([^\"]*)" exists$/ do |short_name|
  @campaign = Factory(:old_campaign, :short_name => short_name)
end

Given /^the campaign has a team with short name "([^\"]*)"$/ do |short_name|
  @team = Factory(:team, :old_campaign => @campaign, :short_name => short_name)
end

Given /^I am logged in as a registered user$/ do
  visit path_to("the home page")
  @current_user = Factory(:user)
  visit path_to("the login page")
  fill_in("login", :with => @current_user.login)
  fill_in("password", :with => "secret")
  click_button("Login")
end

Then /^I should be in the list of participants$/ do
  pending # express the regexp above with the code you wish you had
end
