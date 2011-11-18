Feature: Authenticated users can add a friend

Background:
  Given I am an authenticated user

Scenario: Can find friends
  Given the following users exist:
    | first_name | last_name |
    | Florence   | Bar       |
  And I am on my account page
  When I follow "Find Friends"
  And I should see "Add Friend"

Scenario: Add as friend button on stranger's profile
  When I visit a stranger's profile
  Then I should see "Add as friend"
  When I visit my "profile"
  Then I should not see "Add as friend"

Scenario: When "Add as Friend" link is followed
  When I visit a stranger's profile
  And I follow "Add as friend"
  Then a friendship should be created
  And the friendship status should be "unaccepted"
  And "stranger@example.com" should receive an email
  And I am now authenticated as "stranger@example.com"
  And I open the email
  Then I should see "accept" in the email body
  And I should see "decline" in the email body

Scenario: When "Accept" is clicked
  Given "stranger@example.com" has received a friendship request
  And "stranger@example.com" should receive an email
  And I am now authenticated as "stranger@example.com"
  And I open the email
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

Scenario: Should be able to see all my friendships
  Given I have a friendship that I initiated
  And I have a friendship that my friend initiated
  When I go to my friendships page
  Then I should see all my friends

Scenario: Friends list
  Given I am friends with "stranger@example.com"
  And I visit my "friends list"
  Then I should see "John Doe"
