Given /^I have created a campaign with a url of "([^\"]*)"$/ do |url|
  @campaign = Factory(:campaign, :user => @user, :url => url)
  @campaign.url = url
  @campaign.save
end

Given /^there is an existing campaign$/ do
  @campaign = Factory(:campaign)
end

Given /^I am a participant of the campaign$/ do
  Participant.create(:user => @user, :campaign => @campaign)
end

Then /^I should be a participant in the campaign$/ do
  @user.campaigns.reload.should include(@campaign)
end