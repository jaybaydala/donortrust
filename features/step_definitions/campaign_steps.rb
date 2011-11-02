Given /^I have created a campaign with a url of "([^\"]*)"$/ do |url|
  @campaign = Factory(:campaign, :user => @user, :url => url)
  @campaign.url = url
  @campaign.save
end