Feature: Authenticated users can add a friend

Background:
  Given I am an authenticated user

Scenario: Add as friend button on stranger's profile
  When I visit a stranger's profile
  Then I should see "Add as friend" button
  When I visit my profile
  Then I should not see "Add as friend" button

Scenario: When "Add as Friend" button is pressed
  When I visit a stranger's profile
  And I press "add_as_friend"
  Then a friendship should be created
  And the friendship status should be "unaccepted"  
