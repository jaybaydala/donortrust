Feature: A User adds items to their Cart
  In order to checkout and purchase items
  As a User
  I want to add items to my cart

  Scenario: Adding a gift
    Given I am on the new gift page
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
    And I am on the new gift page
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
    Given I am on the new project investment page
    When I fill in "investment_amount" with "110"
    And I choose the project
    And I press "Add to Cart"
    Then the Investment should appear in the Cart
    And the Cart Total should be $110.00
    And there should be a link to Edit the Investment
    And there should be a link to Remove the Investment
    
  Scenario: Adding a Deposit
    Given I am logged in
    And I am on the new deposit page
    When I fill in "Deposit Amount" with "50"
    And I press "Add to Cart"
    Then the Deposit should appear in the Cart
    And the Cart Total should be $50.00
    And there should be a link to Edit the Deposit
    And there should be a link to Remove the Deposit
    
  Scenario: Cart Paging
    Given I add 11 gifts to the cart
    When I go to "/dt/cart"
    Then I should see 10 gift(s) on the first page of the cart
    And I should see the cart pagination
    And I should see 1 gift(s) on the second page of the cart
