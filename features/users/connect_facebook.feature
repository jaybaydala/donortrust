Feature: Connect Facebook
As a user with an account
I also want to be able to login via facebook
So that I can be kept up to date on UEnd information

Background: logged in
  Given I am an authenticated user

@omniauth_test
Scenario: Connect to facebook
  When I authenticate with Facebook
  Then I should be on the authentications page
  And I should see "Facebook" within the listed authentications
