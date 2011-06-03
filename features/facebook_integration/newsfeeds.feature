# - allows the option to post after buying/receiving gifts, investing, creating/joining campaigns, setting up your profile
Feature: FB newsfeeds
As a user
I should be able to post my activity to my FB feed
So that I can get my friends involved

@pending
Scenario: Post-checkout
  Given that I have added a $10 gift to my cart
  And that I have completed the checkout process
  Then I should be on the order confirmation page
  And I should see the facebook newsfeed post widget

@pending
Scenario: On my profile
  Given I am on the dt account page
  Then I should see the facebook newsfeed post widget

@pending
Scenario: Creating a campaign
  Given I am on the new dt campaign page
  When I create a new campaign
  Then I should see the facebook newsfeed post widget