Feature: Basic checkout with a CC payment
As a user
I want to be able to go through the checkout process
So that I can help to end poverty
Through the purchase of gifts and investments

Background: 
  Given I have added a $10 investment to my cart
  And I have added a $10 gift to my cart
  #And that I have removed the optional donation

Scenario: Successful checkout with fewest options
  Given I am on my cart page
  And I follow "Checkout"
  And I press "Proceed to Step 2"
  And I fill in "First Name" with "John"
  And I fill in "Last Name" with "Smith"
  And I fill in "Street Address" with "123 Avenue Road"
  And I fill in "City" with "Calgary"
  And I fill in "Province/State" with "AB"
  And I fill in "Postal/Zip Code" with "T2Y 3N2"
  And I select "Canada" from "Country"
  And I fill in "Email" with "john.smith@example.com"
  And I uncheck "Please provide me with a tax receipt"
  And I fill in "Credit Card Number" with "1"
  And I fill in "Card Security Number (CVV)" with "989"
  And I select "01" from "order_expiry_month"
  And I select "2018" from "order_expiry_year"
  And I fill in "Cardholder Name" with "Jonathan Smith"
  And I press "Proceed to Step 3"
  And I press "Complete Checkout"
  Then I should be on the order confirmation page
  And I should see "Thank you for helping to change the world."
  And my order should be complete

Scenario: Successful checkout with signup
  Given I am on my cart page
  And I follow "Checkout"
  And I press "Proceed to Step 2"
  And I fill in "First Name" with "John"
  And I fill in "Last Name" with "Smith"
  And I fill in "Street Address" with "123 Avenue Road"
  And I fill in "City" with "Calgary"
  And I fill in "Province/State" with "AB"
  And I fill in "Postal/Zip Code" with "T2Y 3N2"
  And I select "Canada" from "Country"
  And I fill in "Email" with "john.smith@example.com"
  And I fill in "order_password" with "Secret123"
  And I fill in "order_password_confirmation" with "Secret123"
  And I check "I have read the terms of use and agree"
  And I fill in "Credit Card Number" with "1"
  And I fill in "Card Security Number (CVV)" with "989"
  And I select "01" from "order_expiry_month"
  And I select "2018" from "order_expiry_year"
  And I fill in "Cardholder Name" with "Jonathan Smith"
  And I press "Proceed to Step 3"
  And I press "Complete Checkout"
  Then I should be on the order confirmation page
  And I should see "Thank you for helping to change the world."
  And a user account should exist for the email "john.smith@example.com"
