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

Then /^I should see the campaign name$/ do
  @campaign ||= Campaign.last
  steps %Q{
    Then I should see "#{@campaign.name}"
  }
end

When /^I choose the first participant from "([^"]*)"$/ do |arg1|
  #first one is chosen by default... just here for readability
end