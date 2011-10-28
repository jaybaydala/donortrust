# - Add matching gift text upon open 'Your friend gave you a gift to help end global poverty. "Double the impact by matching your friends gift"'
# - UI-wise, this doubles their Gift Card Balance (top-right corner)
# - They go and choose their project(s) and go to checkout
# - Payment Options - they need to pay the extra balance from their credit card
#   - this is all held in the session alone (no db modeling)
#   - Add text "Friend's gift amount     --> $100"
#              "DoubleDown Impact amount --> $100"
#   - $100 gets added as Credit Card amount

Feature: Matching Gifts
  As a user
  I want to be able to Match a Gift I'm receiving
  So that I can double our impact

Background:
  Given I am an authenticated user
  And I have received a $25 gift
   
Scenario: From open to checkout payment options
  Given I am on the open dt gifts page
  And I fill in "Enter your Pickup Code" with my gift pickup code
  And I press "Open"
  Then I should be on the open dt gifts page
  And I should have a $25 gift card balance
  And I should see "Your friend gave you a gift to help end global poverty. Match your friends gift to double the impact."
  When I follow "Match your friends gift"
  Then I should have a $50 gift card balance
  When I have added a $50 investment to my cart
  And I am on my cart page
  And I follow "Checkout"
  And I press "next"
  Then the "Take from my Gift Card" field should contain "25"
  Then the "Put on my Credit Card" field should contain "32.50"
