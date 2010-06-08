Feature: Joining a team
	In order to contribute to the team's overall performance
	As a User
	I want to join a team
	
	Background:
		Given a pre-populated database
		And a campaign with short name "test_campaign" exists
		And the campaign has a team with short name "test_team"
		
	Scenario: Registered user does not belong to the campaign
		Given I am logged in as a registered user
		When I go to the test_team team page
		And I follow "join_this_team"
		Then I should be on the test_campaign campaign page
		And I should be in the list of participants
		
	Scenario: Registered user belongs to the campaign default team
	Scenario: Registered user belongs to a different team