Feature: FB newsfeeds
  As a user
  I should be able to post my activity to my FB feed
  So that I can get my friends involved
  # - allows the option to post after buying/receiving gifts, investing, creating/joining campaigns, setting up your profile

Background:
  Given I am an authenticated user

@omniauth_test
Scenario: Post-checkout
  Given I have authenticated with facebook
  And that I have added a $10 gift to my cart
  And that I have completed the checkout process
  Then I should be on the order confirmation page
  And I should see the facebook newsfeed post widget

@omniauth_test
Scenario: On my profile
  Given I have authenticated with facebook
  And I am on the my account page
  Then I should see the facebook newsfeed post widget

@pending @omniauth_test
Scenario: Creating a campaign
  Given I have authenticated with facebook
  And I am on the new dt campaign page
  When I create a new campaign
  Then I should see the facebook newsfeed post widget