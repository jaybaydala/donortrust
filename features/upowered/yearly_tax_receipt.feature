# - no monthly tax receipt and automated yearly tax receipt for subscriptions
# - Standard receipt with “UPowered Giving” with total for the tax year
# - They still receive a monthly thank you email for their subscription as well as a note that the tax receipt comes yearly
# - Warnings for impending card expiry, please update here (cc info@uend.org)
Feature: Yearly UPowered Tax Receipts
  We want to be able to give users yearly UPowered tax receipts
  So that they don't need to keep track of them every month

Background: UPowered subscription
  Given I have a current $5 UPowered subscription added on January 15, 2010

Scenario: Yearly tax Receipt
  Given it is January 1, 2011
  When the system generates my UPowered tax receipt
  Then the UPowered tax receipt should total $60

Scenario: Card expiry warning
  Given it is May 1, 2011
  And my credit card expiry date is 06/2011
  When the checks for impending credit card expiries
  Then I should receive an email
  When I open the email
  Then I should see "UPowered: Impending credit card expiry" in the email subject
  And I should see "The credit card in our system is scheduled to expire in June, 2011." in the email subject
  