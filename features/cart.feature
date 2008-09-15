Feature: A User adds items to their Cart

In order to checkout and purchase items
As a User
I want to add items to my cart

  Scenario: Adding a gift
    Given that the user has created a gift
    And the Shopping Cart total is $0
    When I fill in "20" for "Amount"
    And I fill in "test1@example.com" for "From Email"
    And I fill in "test2@example.com" for "To Email"
    And I click Add to Cart
    Then the Gift should appear in the Cart
    And there should be a link to Preview the Gift
    And there should be a link to Edit the Gift
    And there should be a link to Remove the Gift
    And the Cart Total should be $20

  Scenario: Adding another gift
    Given that the user has created a gift
    And the Cart already holds an Existing Gift
    And the Existing Gift Amount is $20
    When I fill in "25" for "Amount"
    And I fill in "test1@example.com" for "From Email"
    And I fill in "test2@example.com" for "To Email"
    And I click Add to Cart
    Then the Gift should appear in the Cart
    And there should be a link to Preview the Gift
    And there should be a link to Edit the Gift
    And there should be a link to Remove the Gift
    And the Cart Total should be $45

  Scenario: Adding an Investment
    Given that the user is Investing in a project
    And the Investment Amount is $100
    And the Investment Project id is 5
    When I fill in "100" for "Amount"
    And I choose "5" for "Project"
    And I click Add to Cart
    Then the Investment should appear in the Cart
    And there should be a link to Edit the Investment
    And there should be a link to Remove the Investment
    And the Cart Total should be $100

  Scenario: Adding a Deposit
    Given that the user is logged in
    When I fill in "50" for "Amount"
    And I click Add to Cart
    Then the Deposit should appear in their Cart
    And there should be a link to Edit the Deposit
    And there should be a link to Remove the Deposit
    And the Cart Total should be $50
