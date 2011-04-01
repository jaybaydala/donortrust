Feature: Sign up
  In order to log into the system
  As a user
  I want to register a new account with the system
  
  Scenario: Sign up successfully
    Given I am not authenticated
    And I am on the sign up page
    And I fill in "Username/Email" with "testing@example.com"
    And I fill in "Display Name" with "Test"
    And I fill in "Password" with "secretpass"
    And I fill in "Confirm Password" with "secretpass"
    And I select "Canada" from "Country"
    And I check "user_terms_of_use"
    And I press "Create Account"
    And I should be on the dt accounts page

  Scenario: Sign up unsuccessful
    Given I am not authenticated
    And I am on the sign up page
    And I fill in "Username/Email" with "testing"
    And I fill in "Display Name" with "Test"
    And I fill in "Password" with "secretpass"
    And I fill in "Confirm Password" with "secretpass"
    And I select "Canada" from "Country"
    And I check "user_terms_of_use"
    And I press "Create Account"
    And I should be on the redisplayed sign up page
