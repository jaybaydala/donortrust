Feature: A User uses a portion of their gift card should maintain a balance

In order to use a gift card in multiple visits
As a Gift Receiver
I want to have a balance on my gift card

  Scenario: A new gift card should have a balance equal to the amount
    Given that I am a gift giver
    When I add a gift to my cart
    And checkout
    Then the gift should have a balance equal to the amount

  Scenario: Opening a gift card should tell the balance
    Given that I've received a gift
    When I open the gift
    Then I should be told the gift card balance

  Scenario: Checking out with a gift card should reduce the balance
    Given that I've opened a gift
    When I checkout using part of the balanace
    Then the gift card balance should be updated
    And I can open the gift again and see the balance
