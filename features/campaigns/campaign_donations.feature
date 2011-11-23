Feature: Campaign Donations
As a user
I want to be able to donate to an existing campaign
So that I can help to end poverty

Background:
  Given I am an authenticated user
  And there is an existing campaign
  And the campaign has 2 teams

Scenario: Donate to a campaign
  Given I am on the iend campaign page
  Then I should see "Donate to this campaign"
  When I follow "Donate to this campaign"
  Then I should be on the iend campaign donations page
  And I should see the campaign name
  When I fill in "Amount" with "100"
  And I press "add to cart"
  Then I should be on the dt cart page
  When I have completed the checkout process
  Then I should see "$100" within ".campaign-donation"

Scenario: Donate to a specific team in a campaign
  Given I am on the iend campaign page
  And I follow the team link
  Then I should be on the iend campaign team page
  And I should see "Donate to this team"
  When I follow "Donate to this team"
  Then I should be on the iend campaign donations page
  And I should see the team name
  And I should see the campaign name
  When I fill in "Amount" with "100"
  And I press "add to cart"
  Then I should be on the dt cart page
  When I have completed the checkout process
  Then I should see "$100" within ".campaign-donation"