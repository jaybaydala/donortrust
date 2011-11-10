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

  # Defaults to anonymous name + location, public sectors

  Scenario: Name search on private name
    Given I am on the users page
    When I fill in "Search" with "Rankin"
    And I press "Go"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should see "Anonymous" within ".results"

  Scenario: Location search on private location
    Given I am on the users page
    When I fill in "Search" with "NS"
    And I press "Go"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "NS" within ".results"
    And I should see "Anonymous" within ".results"

  Scenario: Sector search on private name + location
    Given I am on the users page
    When I follow "Good Cause"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "NS" within ".results"
    And I should see "Anonymous" within ".results"

  # Make names public

  Scenario: Search by name on public name
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name
    When I fill in "Search" with "Jimmy"
    And I press "Go"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  Scenario: Search by location on public name
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name
    When I fill in "Search" with "NS"
    And I press "Go"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"

  Scenario: Search by sector on public name
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name
    When I follow "Good Cause"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  # Make location public

  Scenario: Search by name on public location
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public location
    When I fill in "Search" with "Jimmy"
    And I press "Go"
    Then I should see "Anonymous" within ".results"
    And I should see "NS" within ".results"
    And I should not see "ME" within ".results"

  Scenario: Search by location on public location
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public location
    When I fill in "Search" with "NS"
    And I press "Go"
    Then I should see "NS" within ".results"
    And I should not see "ME" within ".results"

  Scenario: Search by sector on public location
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public location
    When I follow "Good Cause"
    Then I should see "NS" within ".results"
    And I should not see "ME" within ".results"

  # Make sectors private

  Scenario: Search by sector on private sector
    Given I am on the users page
    And the iend profile "Jimmy Rankin" has a public name and private sectors
    When I follow "Good Cause"
    Then I should not see "Jimmy Rankin" within ".results"

