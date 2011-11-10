When /^I visit a stranger's profile$/ do
  @user = Factory(:user, :login => "stranger@email.com", :password => "stranger", :password_confirmation => "stranger")
  visit(iend_user_path(@user))
end

When /^I visit my profile$/ do
  visit(iend_user_path(:id => "current"))
end

Then /^a friendship should be created$/ do
  friendship = find_friendship(current_user, @user)
  friendship.should_not be_nil
end

Then /^the friendship status should be "([^"]*)"$/ do |arg1|
  status = arg1 == "accepted" ? true : false
  friendship = find_friendship(current_user, @user)
  friendship.status.should == status
end

Then /^the friendship status should be deleted$/ do
  friendship = find_friendship(current_user, @user)
  friendship.should be_nil
end

Given /^"([^"]*)" has received a friendship request$/ do |arg1|
  Given "I visit a stranger's profile"
  Given "I follow \"add_as_friend\""
end

Then /^initiator should receive (an|no|\d+) email$/ do |amount|
  Then "\"#{current_user.email}\" should receive #{amount} email"
end

def find_friendship(initiator, friend)
  initiator.friendships.find(:first, :conditions => ["friend_id = ?", @user.id])
end

