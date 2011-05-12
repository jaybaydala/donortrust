Feature: Sign up with facebook
As a user who's already on facebook
I also want to be able to login via facebook
So that I don't have to remember another login

Background: not logged in
  Given I am not authenticated

@omniauth_test
Scenario: Signup via facebook connect
  When I authenticate with Facebook
  Then I should be on the new account page
  And I should see "Complete your facebook registration"
  When I select "Canada" from "Country"
  And I check "user_terms_of_use"
  And I press "Complete Registration"
  Then I should be on the accounts page
  And I should see "Signed in successfully"
  And I should see "Welcome, sterrym"
  When I go to the authentications page
  Then I should see "Facebook" within the listed authentications

@omniauth_test
Scenario: Signup via facebook connect with an existing account
  Given the following users exist:
    | login              |
    | jsmith@example.com |
  When I authenticate with Facebook
  Then I should be on the new account page
  And I should see "Already have a UEnd account? Login"
  When I fill in "login" with "jsmith@example.com"
  And I fill in "password" with "Secret123"
  And I press "Link facebook profile"
  Then I should see "Logged in successfully"
  When I go to the authentications page
  Then I should see "Facebook" within the listed authentications
