Feature: A User uses a portion of their gift card should maintain a balance

In order to use a gift card in multiple visits
As a Gift Receiver
I want to have a balance on my gift card

  Scenario: A new gift card should have a balance equal to the amount
    Given I add a gift for $50 to my cart
    And I checkout
    Then the gift card amount should be $50
    Then the gift card balance should be $50
    

  Scenario: Opening a gift card should tell the balance
    Given I have received a gift for $65
    When I open the gift
    Then I should see "Your Gift Card Balance is: $65.00"

  Scenario: Checking out with a gift card should reduce the balance
    Given I have received a gift for $100
    When I open the gift
    And I add an investment for $60 to my cart
    And I checkout
    Then the gift card balance should be $40
  
  Scenario: Reopening a gift should show the current gift balance
    GivenScenario: Checking out with a gift card should reduce the balance
    Given I come back in another browser session
    When I open my gift card again
    Then the gift card balance should be $40
