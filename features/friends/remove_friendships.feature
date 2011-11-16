Feature: Friendships can be removed

Background:
  Given I am an authenticated user

@wip
Scenario: Should be able to remove a friendships from my friends page
  Given I have a friendship
  And I am on my friend's page
  Then I should see "Unfriend"
  When I follow "Unfriend"
  Then I should be on my friendships page
  And I should see /Your friendship with .* has been removed/
