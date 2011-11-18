Feature: Sign up with facebook
As a user who's already on facebook
I also want to be able to login via facebook
So that I don't have to remember another login

Background: not logged in
  Given I am not authenticated

@omniauth_test
Scenario: Signup via facebook connect
  When I authenticate with Facebook
  Then I should be on the new iend user page
  And I should see "Complete Your Registration"
  When I select "Canada" from "Country"
  And I check "I have read the terms of use and agree"
  And I press "Join"
  Then I should be on the iend page
  And I should see "Signed in successfully"
  And I should see "Account Settings"
  When I go to the authentications page
  Then I should see "Facebook" within the listed authentications
  And my birthday should be stored in my account

@omniauth_test
Scenario: Signup via facebook connect with an existing account
  Given the following users exist:
    | login              |
    | jsmith@example.com |
  When I authenticate with Facebook
  Then I should be on the new iend user page
  And I should see "Already have a UEnd account? Login"
  When I fill in "Username/Email" with "jsmith@example.com" within "#user-login"
  And I fill in "Password" with "Secret123" within "#user-login"
  And I press "Link facebook profile"
  Then I should see "Logged in successfully"
  When I go to the authentications page
  Then I should see "Facebook" within the listed authentications
  And my birthday should be stored in my account
