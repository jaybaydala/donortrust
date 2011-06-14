# Add a summary of activity: Beside each project being given to, add an FB "Like" button with "Want to receive project updates? 'Like' this project"
# Post-checkout: Save info into profile (automatically), buy another gift, FB Like
# if they're not logged in: "Login with facebook"
# if they are logged in but have not linked accounts: "Connect via facebook"
Feature: Post-checkout
We want to give some options to the user on their order "thank you" screen.

Background: Load Cart
  Given that I have added a $25 investment to my cart
  And that I have added a $10 gift to my cart

Scenario: Show an activity summary
  When I have completed the checkout process
  Then I should see "Gift" within ".gift"
  And I should see "$10" within ".gift"
  And I should see "Investment" within ".investment"
  And I should see "$25" within ".investment"

@pending
Scenario: Save profile info
  Given I am an authenticated user
  And I have completed the checkout process
  When I go to my account page
  Then I should see "John Smith"
  And I should see "123 Avenue Road"
  And I should see "Calgary"
  And I should see "AB"
  And I should see "T2Y 3N2"
  And I should see "Canada"

Scenario: Facebook login
  Given I have completed the checkout process
  Then I should see "Login with facebook" within "#content"

Scenario: Facebook connect
  Given I am an authenticated user
  And I am on my cart page
  When I have completed the checkout process
  Then I should see "Connect via facebook" within "#content"
