Feature: New user notification
  Admin should receive an email with new user's contact details

  Scenario: Normal Signup
    Given I am not authenticated
    And I am on the sign up page
    And I fill in "Username/Email" with "testing@example.com"
    And I fill in "Password" with "Secret123"
    And I fill in "Confirm Password" with "Secret123"
    And I select "Canada" from "Country"
    And I check "I have read the terms of use and agree"
    And I press "Join"
    Then "jay.baydala@uend.org" should receive an email with the following body:
      """
      testing@example.com has signed up.
      """
