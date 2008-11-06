Feature: Giving a Gift
In order to support ChristmasFuture projects
As a user
I want to be able to give a gift

  Scenario: Adding a gift
    Given I go to "/dt/gifts/new"
    When I fill in "Gift Amount for each recipient" with "20"
    And I fill in "gift[email]" with "test1@example.com"
    And I fill in "gift[email_confirmation]" with "test1@example.com"
    And I fill in "gift[to_email]" with "test2@example.com"
    And I fill in "gift[to_email_confirmation]" with "test2@example.com"
    And I press "Add to Cart"
    Then the Gift should appear in the Cart
    And there should be a link to Preview the Gift
    And there should be a link to Edit the Gift
    And there should be a link to Remove the Gift
    And the Cart Total should be $20

  Scenario: Giving a bulk gift
    Given I go to "/dt/gifts/new"
    When I fill in "gift[name]" with "Test Gift"
    And I fill in "gift[email]" with "tester@example.com"
    And I fill in "gift[email_confirmation]" with "tester@example.com"
    And I fill in "Gift Amount for each recipient" with "20"
    And I fill in "Gift Recipients" with "tester@example.com,example@example.com,bob@example.com"
    And I press "Add to Cart"
    Then I should see 3 gifts in my cart
    And the Cart Total should be $60

  Scenario: Valid file import upload
    Given I go to "/dt/gifts/new"
    When I attach the file at "valid_file.csv" to "email_upload[email_file]"
    Then I should see all the email addresses from the file in "Gift Recipients"

  Scenario: Valid file gift import added to cart
    GivenScenario: Valid file import upload
    When I fill in "gift[email]" with "test1@example.com"
    And I fill in "gift[email_confirmation]" with "test1@example.com"
    And I press "Add to Cart"
    Then I should see 3 gifts in my cart

  Scenario: Invalid file import upload
    Given I go to "/dt/gifts/new"
    When I attach the file at "invalid_file.csv" to "email_upload[email_file]"
    Then I should get an error message with further instructions
