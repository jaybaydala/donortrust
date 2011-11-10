Feature: Authenticated users can add a friend

Background:
  Given I am an authenticated user

Scenario: Add as friend button on stranger's profile
  When I visit a stranger's profile
  Then I should see "Add as friend"
  When I visit my profile
  Then I should not see "Add as friend" button

Scenario: When "Add as Friend" link is followed
  When I visit a stranger's profile
  And I follow "add_as_friend"
  Then a friendship should be created
  And the friendship status should be "unaccepted"
  And "stranger@example.com" should receive an email
  And "stranger@example.com" opens the email
  And they should see "accept" in the email body
  And they should see "decline" in the email body

Scenario: When "Accept" is clicked
  Given "stranger@example.com" has received a friendship request
  And "stranger@example.com" should receive an email
  And "stranger@example.com" opens the email
  And I am now authenticated as "stranger@example.com"
  When I follow "accept" in the email
  Then the friendship status should be "accepted"
  Then the initiator should receive an email

Scenario: When "Decline" is clicked
  Given "stranger@example.com" has received a friendship request
  And "stranger@example.com" should receive an email
  And "stranger@example.com" opens the email
  And I am now authenticated as "stranger@example.com"
  When I follow "decline" in the email
  Then the friendship status should be deleted
  Then the initiator should receive no email
  
