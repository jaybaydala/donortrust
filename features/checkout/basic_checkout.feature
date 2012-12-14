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
  When I follow "Checkout"
  Then I should see "For the monthly price of a cup of coffee, help fund the organization that's ending poverty"
  When I choose "no thanks"
  And I press "next"
  And I uncheck "Please provide me with a tax receipt"
  And I fill in "First name" with "John"
  And I fill in "Last name" with "Smith"
  And I fill in "Street address" with "123 Avenue Road"
  And I fill in "City" with "Calgary"
  And I fill in "Province/State" with "AB"
  And I fill in "Postal/Zip code" with "T2Y 3N2"
  And I select "Canada" from "Country"
  And I fill in "Email" with "john.smith@example.com"
  And I press "next"
  Then I should see "Password"
  And I should see "Password confirmation"
  When I press "next"
  And I fill in "Credit card number" with "4111111111111111"
  And I fill in "Card security number (CVV)" with "989"
  And I select "01" from "order_expiry_month"
  And I select "2018" from "order_expiry_year"
  And I fill in "Cardholder name" with "Jonathan Smith"
  When I press "next"
  Then I should see "Order Summary"
  And I press "finish"
  Then I should be on the order confirmation page
  And I should see "Thank you for helping to change the world."
  And my order should be complete

Scenario: Successful checkout with signup
  Given I am on my cart page
  When I follow "Checkout"
  And I choose "no thanks"
  And I press "next"
  And I fill in "First name" with "John"
  And I fill in "Last name" with "Smith"
  And I fill in "Street address" with "123 Avenue Road"
  And I fill in "City" with "Calgary"
  And I fill in "Province/State" with "AB"
  And I fill in "Postal/Zip code" with "T2Y 3N2"
  And I select "Canada" from "Country"
  And I fill in "Email" with "john.smith@example.com"
  And I press "next"
  And I fill in "order_password" with "Secret123"
  And I fill in "order_password_confirmation" with "Secret123"
  And I check "Terms of use"
  When I press "next"
  And I fill in "Credit card number" with "4111111111111111"
  And I fill in "Card security number (CVV)" with "989"
  And I select "01" from "order_expiry_month"
  And I select "2018" from "order_expiry_year"
  And I fill in "Cardholder name" with "Jonathan Smith"
  And I press "next"
  Then I should see "Order Summary"
  And I press "finish"
  Then I should be on the order confirmation page
  And I should see "Thank you for helping to change the world."
  And a user account should exist for the email "john.smith@example.com"
