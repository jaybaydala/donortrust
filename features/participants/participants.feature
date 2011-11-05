Feature: User Joins A Campaign
As a user
I want to be able to participate in a campaign
So that I can help to end poverty

Background:
  Given I am an authenticated user
  And there is an existing campaign

Scenario: Join an existing campaign
  Given I am on the iend campaign page
  Then I should see "Join this campaign"
  When I follow "Join this campaign"
  Then I should be on the iend campaign page
  And I should be a participant in the campaign
  And I should see "Welcome to the campaign"