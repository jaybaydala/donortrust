Feature: Bulk Gift Giving
  In order to give to many recipients
  As a corporate giver
  I want to be able to create a bulk gift

  Scenario: Link back to "Give a Gift" page
    Given I am any user
    When I go to /dt/bulk_gifts/new
    Then I  will see a link to the "Return to Individual Gift Giving" page

  Scenario: Giving a bulk gift
    Given I go to /dt/bulk_gifts/new
    When I fill in "gift[name]" with "Test Gift"
    And I fill in "gift[email]" with "tester@example.com"
    And I fill in "Gift Amount" with "20"
    And I fill in "Gift Recipients" with "tester@example.com,example@example.com,bob@example.com"
    And I press "Add to Cart"
    Then I should see 3 gifts in my cart
    And my Cart Total should be $60

  Scenario: Valid file import
    Given I go to /dt/bulk_gifts/new
    When I upload a valid file to Import
    Then I should see all the email addresses from the file in "Gift Recipients"

  Scenario: Invalid file import
    Given I go to /dt/bulk_gifts/new
    When I upload an invalid file to Import
    Then I should get an error message with further instructions
