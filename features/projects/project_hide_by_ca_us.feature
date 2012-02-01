Feature: Show or Hide Projects Based on Geolocation
  I want to show projects with ca? == true to Canadian visitors
  and show projects with us? == true to U.S. visitors

  Background:
    Given the project statuses are setup
	And the following projects
	| name                | status | sectors           | location     | partners       | total_cost  |
	| Small Project       | active | Education,Health  | Turbekistan  | Tag Solutions  | 2500        |
	| Large Project       | active | Health            | Cape Breton  | ACME Hardware  | 12000       |
	And the project "Small Project" is not visible in Canada
	And the project "Large Project" is not visible in the U.S.
	And the project indexes are processed

  Scenario: Project Show, Visitor from Canada
  	Given I am visiting from Canada
	Then I should not be able to visit the projects page for "Small Project"

  Scenario: Project List, Visitor from Canada
  	Given I am visiting from Canada
	When I go to the projects page
	Then I should see "[CA]" within ".quiet"
	And I should not see "Small Project"
	And I should see "Large Project"

  Scenario: Project Search, Visitor from Canada
  	Given I am visiting from Canada
	When I go to the projects page
	Then I should see "[CA]" within ".quiet"
	And I follow "Active"
	And I should not see "Small Project"
	And I should see "Large Project"

  Scenario: Project Show, Visitor from the U.S.
  	Given I am visiting from the U.S.
	Then I should not be able to visit the projects page for "Large Project"

  Scenario: Project List, Visitor from U.S.
  	Given I am visiting from the U.S.
	When I go to the projects page
	Then I should see "[US]" within ".quiet"
	And I should see "Small Project"
	And I should not see "Large Project"

  Scenario: Project Search, Visitor from U.S.
  	Given I am visiting from the U.S.
	When I go to the projects page
	Then I should see "[US]" within ".quiet"
	And I follow "Active"
	And I should see "Small Project"
	And I should not see "Large Project"

  Scenario: Prevent hidden projects from being added as Gift
  	Given I am visiting from the U.S.
	Then I shouldn't be able to add the project "Large Project" as a gift

  Scenario: Prevent hidden projects from being added as Investments
  	Given I am visiting from Canada
	Then I shouldn't be able to add the project "Small Project" as an investment