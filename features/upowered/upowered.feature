Feature: Upowered
We want users to have the UPowered option available in their cart by default
So that they know that we need funding too

@pending
Scenario: Checkout without changes
  Given that I have added a $10 investment to my cart
  When I am on the dt cart page
  Then I should see that UPowered is in my cart for $5
  When that I have completed the checkout process
  Then I should have 1 UPowered subscription for $5

@pending
Scenario: Checkout with adjustment
  Given that I have added a $10 investment to my cart
  When I am on the dt cart page
  Then I should see that UPowered is in my cart for $5
  When I follow "Adjust your monthly amount"
  Then I should see a radio button for a $5 UPowered subscription
  And I should see a radio button for a $10 UPowered subscription
  And I should see a radio button for a $25 UPowered subscription
  And I should see a radio button for a $100 UPowered subscription
  And I should see a text field for a custom UPowered subscription
  When I choose $25
  And press "Save Amount"
  Then I should be on the dt cart page
  Then I should see that UPowered is in my cart for $25
  When I have completed the checkout process
  Then I should have 1 UPowered subscription for $25
