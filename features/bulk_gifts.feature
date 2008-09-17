Feature: Bulk Gift Giving
 In order to give to many recipients
 As a corporate giver
 I want to be able to create a bulk gift

 Scenario: Link back to "Give a Gift" page
   Given that I am any user
   When I am on the bulk gift giving page
   Then I  will see a link to the "Return to Individual Gift Giving" page

 Scenario: Giving a bulk gift
   Given that I'm on the bulk gift giving page
   When I enter "Test Gift" for "gift[name]"
   And I enter "tester@example.com" for "gift[email]"
   And I enter "20" for "Amount"
   And I enter "tester@example.com,example@example.com,bob@example.com" for "Gift Recipients"
   Then I should see 3 gifts in my cart
   And my Cart Total should be $60

 Scenario: Valid file import
   Given that I'm on the bulk gift giving page
   When I upload a valid file to Import
   Then I should see all the email addresses from the file in "Gift Recipients"

 Scenario: Invalid file import
   Given that I'm on the bulk gift giving page
   When I upload an invalid file to Import
   Then I should get an error message with further instructions