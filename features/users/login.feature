Feature: Sign in
  In order to use the system's functionality
  As a user
  I want to be able to log into the system

  Scenario: Sign in successfully
    Given I am an authenticated user
    Then I should see "Logged in successfully"
    And I should be on the home page
  
  Scenario: Invalid login credentials
    Given I signed up as "testing@example.com" with password "secretpass"
    When I go to the login page
    And I fill in "Username/Email" with "testing@example.com"
    And I fill in "Password" with "wrongpass"
    And I press "Login"
    Then I should see "Either your username or password are incorrect"
    And I should be on the redisplayed login page
  
  # Scenario: User account is locked
  #   Given I signed up as "testing@example.com" with password "secretpass"
  #   And I confirmed my email address
  #   And my account is locked
  #   When I go to the sign in page
  #   And I fill in "user_email" with "testing@example.com"
  #   And I fill in "user_password" with "secretpass"
  #   And I press "Sign in"
  #   Then I should see "Your account is locked"
  #   And I should be on the redisplayed sign in page