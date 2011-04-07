Feature: Sign up with facebook
As a user who's already on facebook
I also want to be able to login via facebook
So that I don't have to remember another login

Background: not logged in
  Given I am not authenticated

@wip @omniauth_test
Scenario: Signup via facebook connect
  When I authenticate with Facebook
  And I allow donortrust access to my facebook account
  Then I should be on the new account page
  Then show me the page
