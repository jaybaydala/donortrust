Feature: Submit Feedback
  In order to submit feedback
  The name and email default to the currently logged in user
  I fill out and submit the feedback form

  Scenario: Submit feedback successfully while not signed in
    Given I am not authenticated
    And I am on the home page
    And I fill in "Name" with "Andrew Roth"
    And I fill in "Email" with "testing@example.com"
    And I fill in "Subject" with "Subject123"
    And I fill in "Message" with "Message123"
    And I press "feedback_submit"
    Then the last feedback record should have "name" value "Andrew Roth"
    Then the last feedback record should have "email" value "testing@example.com"
    Then the last feedback record should have "subject" value "Subject123"
    Then the last feedback record should have "message" value "Message123"
    Then a feedback record should be created with name "Andrew Roth", email "testing@example.com", subject "Subject123", message "Message123" and resolved "false"
    And "info@uend.org" should receive an email
    When "info@uend.org" opens the email
    Then they should see "Andrew Roth" in the email body
    And they should see "testing@example.com" in the email body
    And they should see "Feedback: Subject123" in the email subject
    And they should see "Message123" in the email body

  Scenario: 
    Given I am logged in
    And I am on the home page
    And the "feedback_name" field should contain the current user's name
    And the "feedback_email" field should contain the current user's email
