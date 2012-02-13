Feature: Upowered New Subscription Notification
Deliver a new subscription notification to Jay Baydala

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
  Then "jay.baydala@uend.org" should receive an email

