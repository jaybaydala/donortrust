Then /^I should see the facebook newsfeed post widget$/ do
  page.should have_css("#facebook_post")
  page.should have_css("#facebook_message")
end
