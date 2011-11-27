Feature: Campaign Donations
As a user
I want to be able to donate to an existing campaign
So that I can help to end poverty

Background:
  Given I am an authenticated user
  And there is an existing campaign
  And the campaign has 2 teams
  And each team has 3 members

Scenario: Donate to a campaign
  Given I am on the iend campaign page
  Then I should see "Donate to this campaign"
  When I follow "Donate to this campaign"
  Then I should be on the iend campaign campaign donations page
  And I should see the campaign name
  When I fill in "Amount" with "100"
  And I choose the first participant from "Donate to"
  And I press "add to cart"
  Then I should be on the dt cart page
  When I have completed the checkout process
  Then I should see "$100" within ".campaign_donation"
  And I should see the name of the team member I donated to

Scenario: Donate to a specific team member in a campaign
  Given I am on the iend campaign page
  And I follow the team link
  Then I should be on the iend campaign team page
  And I should see a list of team members
  And I should see "Donate" next to each team member
  When I follow "Donate" next to the first team member
  Then I should be on the iend campaign campaign donations page
  And I should see the team name
  And I should see the campaign name
  And I should see the team member name
  When I fill in "Amount" with "100"
  And I press "add to cart"
  Then I should be on the dt cart page
  When I have completed the checkout process
  Then I should see "$100" within ".campaign_donation"
  And I should see the team member name