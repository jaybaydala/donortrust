When /^I visit a stranger's profile$/ do
  @user = Factory(:user, :login => "stranger@email.com", :password => "stranger", :password_confirmation => "stranger")
  visit(iend_user_path(@user))
end

When /^I visit my profile$/ do
  visit(iend_user_path(:id => "current"))
end
