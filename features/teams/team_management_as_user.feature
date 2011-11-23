Feature: Basic Team Management
As a user
I want to be able to create and update a team for a campaign
So that I can help to end poverty

Background:
  Given I am an authenticated user
  And there is an existing campaign
  And I am a participant of the campaign

Scenario: Create a new team
  Given I am on the iend campaign page
  Then I should see "No Teams have been created yet"
  And I should see "Add a new team"
  When I follow "Add a new team"
  Then I should be on the new iend campaign team page
  When I fill in "Name" with "My Awesome Team"
  And I fill in "Description" with "Let's rails some money!"
  And I fill in "Goal" with "125.00"
  And I press "Create Team"
  Then I should be on the newly created iend campaign team page
  And I should be a member of the team
  And I should see "Your new team was created"

Scenario: Leave a team I am a member of
  Given the campaign has 1 teams
  And I am a member of one of the teams
  And I am on the iend campaign page
  And I follow the team link
  Then I should be on the iend campaign team page
  And I should not see "Join Team"
  And I should see "Leave Team"
  When I follow "Leave Team"
  Then I should be on the iend campaign team page
  And I should see "You have left the team"
  And I should see "Join Team"