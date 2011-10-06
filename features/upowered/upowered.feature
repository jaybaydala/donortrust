# Put into checkout as a default option: 
# - this means reworking the subscription to only take subscription items instead of the whole cart)
# - beside the mailing list opt in ("Join UPowered - for the monthly price of a cup of coffee, help fund the organization that's ending poverty")
# - if they leave it checked, link to "Adjust your monthly amount", which links back to the UPowered edit page (4 buttons, etc)
# 
# Multiple U:Powered Tiers (popup or separate page):
# - $5, $10, $25, $100, you choose (4 buttons and one text field a button

Feature: Upowered
We want users to have the UPowered option available in their cart by default
So that they know that we need funding too

Background:
  Given I am on the new upowered page
  And I choose "$5.00"
  And I press "Join"

Scenario: Checkout without changes
  Given I am on the dt cart page
  And I follow "Checkout"
  Then I should see "For the monthly price of a cup of coffee, help fund the organization that's ending poverty"
  When I press "next"
  Then I should see "Cart Total: $5.00"
  When I have completed the checkout process, maintaining my upowered, signing up along the way
  Then I should have 1 UPowered subscription for $5

Scenario: Checkout with $10 Investment
  Given I have added a $10 investment to my cart
  And I am on the dt cart page
  When I follow "Checkout"
  Then I should see "For the monthly price of a cup of coffee, help fund the organization that's ending poverty"
  When I press "next"
  Then I should see "Cart Total: $16.50"
  When I have completed the checkout process, maintaining my upowered, signing up along the way
  Then I should have 1 UPowered subscription for $5

@pending
Scenario: Checkout with adjustment
  Given I am on the dt cart page
  And I follow "Checkout"
  Then I should see a radio button for a $5 UPowered subscription
  And I should see a radio button for a $10 UPowered subscription
  And I should see a radio button for a $25 UPowered subscription
  And I should see a radio button for a $100 UPowered subscription
  And I should see a text field for a custom UPowered subscription
  When I choose $25
  And press "next"
  Then I should see "Cart Total: $25.00"
  When I have completed the checkout process, signing up along the way
  Then I should have 1 UPowered subscription for $25
