Feature: Edit Account
  In order to maintain my account
  As a user
  I want to be able to edit my account

  Background:
    Given I am an authenticated user
    And there is a poverty sector "Good Cause"

  Scenario: Individual Name
	Given I go to my iend user page
	And I follow "Edit Account"
	And I fill in "First name" with "John"
	And I fill in "Last name" with "Doe"
	When I submit the user form
	Then I should be on my iend user page
	And I should see "John"
	And I should see "Doe"
