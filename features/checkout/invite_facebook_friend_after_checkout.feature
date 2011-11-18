Feature: Basic checkout with a CC payment
As a user, after the checkout
I want to be able to invite my friends on facebook
So they can support too

Background: logged in
  Given I am an authenticated user

@pending @omniauth_test
Scenario: Invite friends after checkout
  Given I have allowed access to my facebook account
  And that I have added a $10 investment to my cart
  And that I have completed the checkout process
  Then I should be on the order confirmation page
  And I should see the facebook invite friends widget
