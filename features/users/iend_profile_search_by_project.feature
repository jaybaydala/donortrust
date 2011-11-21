@no-txn
Feature: iEnd Profile Search by Project
  In order to find users funding specific projects
  As a user with an account
  I want to be able to search for users by project

  Background: Logged in
    Given I am an authenticated user
    And there is a project named "First Sample Project"
    And there is a project named "Second Sample Project"
    And there is an iend profile named "Jimmy Rankin" who has invested in "First Sample Project"
    And there is an iend profile named "Rita Rankin" who has invested in "Second Sample Project"
    And the iend profile indexes are processed

  Scenario: Search by project on public list, private name (defaults)
    Given I have searched iend profiles by the project "First Sample Project"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should see "Anonymous" within ".results"

  Scenario: Search by project on public list, public name
    Given the iend profile "Jimmy Rankin" has a public name
    And I have searched iend profiles by the project "First Sample Project"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  Scenario: Search by project on private list, public name
    Given the iend profile "Jimmy Rankin" chose not to list projects funded
    And I have searched iend profiles by the project "First Sample Project"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"