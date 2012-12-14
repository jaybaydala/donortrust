Given /^I have removed the optional donation$/ do
  steps %Q{
    Given I am on the dt cart page
    And I follow "Edit" within "#optional_donation"
    And I select "0" from "Your donation"
    And I press "Save"
  }
end

Given /^I have completed the checkout process, maintaining my upowered, signing up along the way$/ do
  steps %Q{
    Given I am on the dt cart page
    When I follow "Checkout"
    And I press "next"
    And I check "Please provide me with a tax receipt"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Smith"
    And I fill in "Street address" with "123 Avenue Road"
    And I fill in "City" with "Calgary"
    And I fill in "Province/State" with "AB"
    And I fill in "Postal/Zip code" with "T2Y 3N2"
    And I select "Canada" from "Country"
    And I fill in "Email" with "john.smith@example.com"
    And I press "next"
    And I fill in "Password" with "secret123"
    And I fill in "Password confirmation" with "secret123"
    And I check "Terms of use"
    And I press "next"
    And I fill in "Credit card number" with "4111111111111111"
    And I fill in "Card security number (CVV)" with "989"
    And I select "01" from "order_expiry_month"
    And I select "2018" from "order_expiry_year"
    And I fill in "Cardholder name" with "Jonathan Smith"
    And I press "next"
    And I press "finish"
    Then I should be on the order confirmation page
    And a user account should exist for the email "john.smith@example.com"
  }
  @user = @current_user = User.last
end

Given /^I have completed the checkout process, signing up along the way$/ do
  steps %Q{
    Given I am on the dt cart page
    When I follow "Checkout"
    And I choose "no thanks"
    And I press "next"
    And I check "Please provide me with a tax receipt"
    And I fill in "First name" with "John"
    And I fill in "Last name" with "Smith"
    And I fill in "Street address" with "123 Avenue Road"
    And I fill in "City" with "Calgary"
    And I fill in "Province/State" with "AB"
    And I fill in "Postal/Zip code" with "T2Y 3N2"
    And I select "Canada" from "Country"
    And I fill in "Email" with "john.smith@example.com"
    And I press "next"
    And I fill in "Password" with "secret123"
    And I fill in "Password confirmation" with "secret123"
    And I check "Terms of use"
    And I press "next"
    And I fill in "Credit card number" with "4111111111111111"
    And I fill in "Card security number (CVV)" with "989"
    And I select "01" from "order_expiry_month"
    And I select "2018" from "order_expiry_year"
    And I fill in "Cardholder name" with "Jonathan Smith"
    And I press "next"
    And I press "finish"
    Then I should be on the order confirmation page
    And a user account should exist for the email "john.smith@example.com"
  }
  @user = @current_user = User.last
end


Given /^I have completed the checkout process$/ do
  steps %Q{
    Given I am on the dt cart page
    When I follow "Checkout"
    And I choose "no thanks"
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
  }
  # this is the signup screen - it doesn't show up if you're authenticated
  unless @current_user
    And "I press \"next\""
  end
  steps %Q{
    And I fill in "Credit card number" with "4111111111111111"
    And I fill in "Card security number (CVV)" with "989"
    And I select "01" from "order_expiry_month"
    And I select "2018" from "order_expiry_year"
    And I fill in "Cardholder name" with "Jonathan Smith"
    And I press "next"
    And I press "finish"
    Then I should be on the order confirmation page
  }
end

Then /^my order should be complete$/ do
  @order ||= Order.last
  @order.complete.should be_true
end
