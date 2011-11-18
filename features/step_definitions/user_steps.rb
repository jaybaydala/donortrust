module UserHelpers
  def current_user
    return @current_user if defined?(@current_user)
  end

  def password
    "Secret123"
  end
end
World(UserHelpers)

Given /^I am not(?: currently)? authenticated$/ do
  visit('/logout') # ensure that at least
end

Given /^I am logged in$/ do
  Given "I am an authenticated user"
end

Given /^I signed up as "([^\"]+)" with password "([^\"]+)"$/ do |email, password|
  @user = Factory(:user, :login => email, :password => password, :password_confirmation => password)
end
Given /^I am an authenticated user$/ do
  @user = @current_user = Factory(:user)
  Given "I am on the login page"
  Given "I fill in \"Username/Email\" with \"#{@user.login}\""
  Given "I fill in \"Password\" with \"Secret123\""
  Given "I press \"Login\""
end

Given /^I am (?:now )?authenticated as \"([^\"]+)\"$/ do |email|
  Given "I am not authenticated"
  @user = @current_user = User.find_by_login(email)
  Given "I am on the login page"
  Given "I fill in \"Username/Email\" with \"#{@user.login}\""
  Given "I fill in \"Password\" with \"Secret123\""
  Given "I press \"Login\""
end

When /^I authenticate as \"([^\"]+)\"$/ do |email|
  Given "I am authenticated as \"#{email}\""
end

Then /^a user account should exist for the email "(.*)"$/ do |email|
  User.find_by_login!(email)
end

Then /^my birthday should be stored in my account$/ do
  @user ||= @current_user || User.last
  @user.birthday.should_not be_nil
end

Then /^my contact information should be updated to match the checkout data$/ do
  @user ||= @current_user || User.last
  @user.reload
  @user.address.should eql "123 Avenue Road"
  @user.city.should eql "Calgary"
  @user.province.should eql "AB"
  @user.postal_code.should eql "T2Y 3N2"
  @user.country.should eql "Canada"
end
