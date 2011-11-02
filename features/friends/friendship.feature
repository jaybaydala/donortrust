Feature: Authenticated users can add a friend

Background:
  Given I am an authenticated user

Scenario: Add as friend button
  When I visit a stranger's profile
  Then I should see "Add as friend"
