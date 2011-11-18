@no-txn
Feature: iEnd Profile Search
  In order to find other users
  As a user with an account
  I want to be able to search for users by name, location and poverty sectors

  Background: logged in
    Given I am an authenticated user
    And there is a poverty sector "Good Cause"
    And there is a poverty sector "Another Cause"
    And there is an iend profile named "Jimmy Rankin" from "NS" with poverty sector "Good Cause"
    And there is an iend profile named "Rita Rankin" from "ME" with poverty sector "Another Cause"
    And the iend profile indexes are processed

  # Private name, public sectors (defaults)

  Scenario: Name search on private name
    Given I am on the users page
    When I fill in "name" with "Rankin"
    And I press "Go"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  Scenario: Sector search on private name
    Given I am on the users page
    When I follow "Good Cause"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should see "Anonymous" within ".results"

  # Public name

  Scenario: Search by name on public name
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name
    When I fill in "name" with "Jimmy"
    And I press "Go"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  Scenario: Search by sector on public name
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name
    When I follow "Good Cause"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  # Private sectors

  Scenario: Search by sector on private sector
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name and private sectors
    When I follow "Good Cause"
    Then I should not see "Jimmy Rankin" within ".results"

