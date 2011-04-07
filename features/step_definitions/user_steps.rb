# module UserHelpers
#   def current_user
#     return @current_user if defined?(@current_user)
#   end
# 
#   def password
#     "Secret123"
#   end
# end
# World(UserHelpers)


Given /^I am not authenticated$/ do
  visit('/dt/logout') # ensure that at least
end

Given /^I am logged in$/ do
  Given "I am an authenticated user"
end

Given /^I signed up as "([^\"]+)" with password "([^\"]+)"$/ do |email, password|
  @user = Factory(:user, :login => email, :password => password, :password_confirmation => password)
end
Given /^I am an authenticated user$/ do
  @user = Factory(:user)
  Given "I am on the login page"
  Given "I fill in \"Username/Email\" with \"#{@user.login}\""
  Given "I fill in \"Password\" with \"Secret123\""
  Given "I press \"Login\""
end