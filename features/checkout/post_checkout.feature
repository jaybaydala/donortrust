# Post-checkout: Save info into profile (automatically), buy another gift, FB Like
# Add a summary of activity: Beside each project being given to, add an FB "Like" button with "Want to receive project updates? 'Like' this project"
# if they're not logged in: "Login with facebook"
# if they are logged in but have not linked accounts: "Connect via facebook"
Feature: Post-checkout
We want to give some options to the user on their order "thank you" screen.

Background: Load Cart
  Given that I have added a $25 investment to my cart
  And that I have added a $10 gift to my cart

@pending
Scenario: Show an activity summary
  When I have completed the checkout process
  Then I should see "Gift" within ".gift"
  And I should see "$10" within ".gift"
  And I should see "Investment" within ".investment"
  And I should see "$25" within ".investment"

@pending
Scenario: Facebook login
  Given that I am not currently authenticated
  When I have completed the checkout process
  Then I should see "Login with facebook"

@pending
Scenario: Facebook connect
  Given that I am an authenticated user
  When I have completed the checkout process
  Then I should see "Connect via facebook"
