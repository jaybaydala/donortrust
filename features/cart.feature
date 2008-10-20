Feature: A User adds items to their Cart
  In order to checkout and purchase items
  As a User
  I want to add items to my cart

  Scenario: Adding a gift
    Given that I am on the new gift page
    When I fill in "Gift Amount" with "20"
    And I fill in "gift_email" with "test1@example.com"
    And I fill in "gift_email_confirmation" with "test1@example.com"
    And I fill in "gift_to_email" with "test2@example.com"
    And I fill in "gift_to_email_confirmation" with "test2@example.com"
    And I press "Add to Cart"
    Then the Gift should appear in the Cart
    And the Cart Total should be $20.00
    And there should be a link to Preview the Gift
    And there should be a link to Edit the Gift
    And there should be a link to Remove the Gift

  Scenario: Adding another gift
    Given the Cart holds an Existing Gift of $20
    And that I am on the new gift page
    When I fill in "Gift Amount" with "25"
    And I fill in "gift_email" with "test1@example.com"
    And I fill in "gift_email_confirmation" with "test1@example.com"
    And I fill in "gift_to_email" with "test2@example.com"
    And I fill in "gift_to_email_confirmation" with "test2@example.com"
    And I press "Add to Cart"
    Then the Gift should appear in the Cart
    And the Cart Total should be $45.00
    And there should be a link to Preview the Gift
    And there should be a link to Edit the Gift
    And there should be a link to Remove the Gift
    
  Scenario: Adding an Investment
    Given that I am on the new project investment page
    When I fill in "investment_amount" with "110"
    And I choose the project
    And I press "Add to Cart"
    Then the Investment should appear in the Cart
    And the Cart Total should be $110.00
    And there should be a link to Edit the Investment
    And there should be a link to Remove the Investment
    
  Scenario: Adding a Deposit
    Given that I am logged in
    And I am on the new deposit page
    When I fill in "Deposit Amount" with "50"
    And I press "Add to Cart"
    Then the Deposit should appear in the Cart
    And the Cart Total should be $50.00
    And there should be a link to Edit the Deposit
    And there should be a link to Remove the Deposit
