Feature: Hide Project Based on Geolocation
  I want to hide projects with ca? == false from Canadian visitors
  and hide projects with us? == false from U.S. visitors

  Background:
	Given the following projects
	| name                | status | sectors           | location     | partners       | total_cost  |
	| Small Project       | active | Education,Health  | Turbekistan  | Tag Solutions  | 2500        |
	| Large Project       | active | Health            | Cape Breton  | ACME Hardware  | 12000       |
	And the project "Small Project" is not visible in Canada
	And the project "Large Project" is not visible in the U.S.
	And the project indexes are processed

  Scenario: Visitor from Canada
  	Given I am visiting from Canada
	When I go to the projects page
	Then I should see "[CA]" within ".quiet"
	And I should not see "Small Project"
	And I should see "Large Project"

  Scenario: Visitor from U.S.
  	Given I am visiting from the U.S.
	When I go to the projects page
	Then I should see "[US]" within ".quiet"
	And I should see "Small Project"
	And I should not see "Large Project"