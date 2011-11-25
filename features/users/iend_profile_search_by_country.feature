@no-txn
Feature: iEnd Profile Search by Country
  In order to find users funding projects in specific countries
  As a user with an account
  I want to be able to search for users by funded country

  Background: Logged in
    Given I am an authenticated user
    And there is a project named "El Salvador Sample Project" in the country "El Salvador"
    And there is a project named "Nepal Sample Project" in the country "Nepal"
    And there is an iend profile named "Jimmy Rankin" who has invested in "El Salvador Sample Project"
    And there is an iend profile named "Rita Rankin" who has invested in "Nepal Sample Project"
    And the iend profile indexes are processed

  Scenario: Search by country on private location & name (defaults)
    Given I have searched iend profiles by the country "El Salvador"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"

  Scenario: Search by country on public location, private name
    Given the iend profile "Jimmy Rankin" has a public location
    And I have searched iend profiles by the country "El Salvador"
    Then I should not see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should see "Anonymous" within ".results"

  Scenario: Search by country on public location & name
    Given the iend profile "Jimmy Rankin" has a public location and name
    And I have searched iend profiles by the country "El Salvador"
    Then I should see "Jimmy Rankin" within ".results"
    And I should not see "Rita Rankin" within ".results"
    And I should not see "Anonymous" within ".results"