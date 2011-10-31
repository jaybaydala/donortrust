Given /^I have created a campaign with a url of "(.*)"$/ do |url|
  @campaign = Factory(:campaign, :user => current_user, :url => url)
end