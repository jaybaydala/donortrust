Feature: Join A Team Rules
As a user
I want to be able to join a team for a campaign
So that I can help to end poverty

Background:
  Given I am an authenticated user
  And there is an existing campaign
  And the campaign has 2 teams

Scenario: Join an existing team
  Given I am on the iend campaign page
  And I follow the team link
  Then I should be on the iend campaign team page
  When I follow "Join Team"
  Then I should be on the iend campaign team page
  And I should be a member of the team
  And I should see "Welcome to the team"

Scenario: Try to join a second team for the same campaign
  Given I am a member of one of the teams
  And I am on the iend campaign page
  When I visit the iend campaign team page for the other team
  And I should not see "Join Team"