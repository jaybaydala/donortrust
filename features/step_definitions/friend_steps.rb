Given /^I have a friendship(?: that I initiated)?$/ do
  @initiator = current_user
  @friend = Factory(:user, :login => "stranger@example.com")
  @friendship = Factory(:friendship, :user => @initiator, :friend => @friend, :status => true)
end

Given /^I have a friendship that my friend initiated$/ do
  @inverse_friend = Factory(:user)
  @inverse_friendship = Factory(:friendship, :user => current_user, :friend => @friend, :status => true)
end

Then /^I should see my friend$/ do
  Then "I should see \"#{@friend.name}\""
end

Then /^I should see all my friends$/ do
  (current_user.friends + current_user.inverse_friends).each do |friend|
    Then "I should see \"#{friend.name}\""
  end
end

When /^I visit a stranger's profile$/ do
  @initiator = @user
  @stranger = Factory(:user, :login => "stranger@example.com")
  visit(iend_user_path(@stranger))
end

When /^I visit my profile$/ do
  visit(iend_user_path(:id => "current"))
end

Then /^a friendship should be created$/ do
  friendship = find_friendship(@initiator, @stranger)
  friendship.should_not be_nil
end

Then /^the friendship status should be "([^"]*)"$/ do |arg1|
  status = arg1 == "accepted" ? true : false
  friendship = find_friendship(@initiator, @stranger)
  friendship.status.should == status
end

Then /^the friendship status should be deleted$/ do
  friendship = find_friendship(@initiator, @stranger)
  friendship.should be_nil
end

Given /^"([^"]*)" has received a friendship request$/ do |arg1|
  Given "I visit a stranger's profile"
  Given "I follow \"add_as_friend\""
end

Then /^the initiator should receive (an|no|\d+) email$/ do |amount|
  Then "\"#{@initiator.email}\" should receive #{amount} email"
end

def find_friendship(initiator, friend)
  initiator.friendships.find_by_friend_id(@stranger)
end
