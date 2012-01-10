Feature: Yearly UPowered Tax Receipts
  We want to be able to give users yearly UPowered tax receipts
  So that they don't need to keep track of them every month
  # - no monthly tax receipt and automated yearly tax receipt for subscriptions
  # - Standard receipt with “UPowered Giving” with total for the tax year
  # - They still receive a monthly thank you email for their subscription as well as a note that the tax receipt comes yearly
  # - Warnings for impending card expiry, please update here (cc info@uend.org)

Background: UPowered subscription
  Given I have a current $1 UPowered subscription added on January 15, 2010

Scenario: Yearly tax Receipt
  Given it is the date January 1, 2011
  And all of my subscriptions have run successfully
  When the system generates my UPowered tax receipt
  Then the UPowered tax receipt should total $12

Scenario: Monthly Thank yous
  Given it is the date February 15, 2010
  And my subscription has run successfully
  Then the subscriber should receive an email
  When I open the email
  Then I should see "UPowered: Thank you!" in the email subject
  And I should see "Your UPowered subscription has run successfully" in the email body

Scenario: Monthly Warning on failure
  And it is the date January February 15, 2010
  And my subscription has failed
  Then the subscriber should receive an email
  When I open the email
  Then I should see "UPowered: Subscription Problem" in the email subject
  And I should see "We just tried to run your UPowered subscription and ran into a problem with your credit card" in the email body

Scenario: Card expiry warning
  Given the subscription credit card expiry date is 06/2011
  And it is the date June 1, 2011
  When the system checks for impending subscription credit card expirations
  Then the subscriber should receive an email
  When they open the email
  Then they should see "UPowered: Impending credit card expiry" in the email subject
  And they should see "the credit card we have in our system for your UPowered subscription is due to expire in 06/2011" in the email body
  