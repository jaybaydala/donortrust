Feature: Login Facebook
As a user with an account that's already linked to facebook
I also want to be able to login via facebook
So that I can be kept up to date on UEnd information

Background: logged in
  Given I am an authenticated user
  And I have allowed access to my facebook account
  And I am not currently authenticated

@omniauth_test
Scenario: login Via facebook
  Given I am on the home page
  When I authenticate with facebook
  Then I should be on my account page
