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
  And "stranger@email.com" should receive an email
  And "stranger@email.com" opens the email
  And they should see "accept" in the email body
  And they should see "decline" in the email body

Scenario: When "Accept" is clicked
  Given "stranger@email.com" has received a friendship request
  And "stranger@email.com" should receive an email
  And "stranger@email.com" opens the email
  When they follow "accept" in the email
  Then the friendship status should be "accepted"
  Then initiator should receive an email

Scenario: When "Decline" is clicked
  Given "stranger@email.com" has received a friendship request
  And "stranger@email.com" should receive an email
  And "stranger@email.com" opens the email
  When they follow "decline" in the email
  Then the friendship status should be deleted
  Then initiator should receive no email
  
