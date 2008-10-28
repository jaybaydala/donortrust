Feature: A User goes to Checkout and pay for their Cart
  In order to pay for the items in my Cart
  As a User
  I want to checkout

  Scenario: First step of checkout
    Given my cart has 2 $20 gifts in it
    And my cart has an investment of $50
    And my cart has a deposit of $200
    And I am starting the checkout process
    When I choose "fund_cf_no"
    And I press "Proceed to Step 2"
    Then I should be on the payment step of the checkout process

  Scenario: Second step of checkout
    GivenScenario: First step of checkout
    When I press "Proceed to Step 3"
    Then I should be on the billing step of the checkout process

  Scenario: Third step of checkout
    GivenScenario: Second step of checkout
    When I fill in "order_first_name" with "Test"
    And I fill in "order_last_name" with "Name"
    And I fill in "order_address" with "123 Hithere St."
    And I fill in "order_city" with "Calgary"
    And I fill in "order_province" with "AB"
    And I fill in "order_postal_code" with "T2Y 3N2"
    And I select "Canada" from "order_country"
    And I fill in "order_email" with "test@example.com"
    And I fill in "order_card_number" with "1"
    And I fill in "order_cvv" with "Name"
    And I select "04" from "order_expiry_month"
    And I select "2012" from "order_expiry_year"
    And I fill in "order_cardholder_name" with "Test User"
    And I press "Proceed to Step 4"
    Then I should be on the confirmation step of the checkout process

  Scenario: Final step of checkout
    GivenScenario: Third step of checkout
    When I press "Complete Checkout"
    Then I should be shown my order
