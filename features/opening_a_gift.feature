Feature: Opening a Gift
  So that I can choose how to allocate the money that was given to me
  As a gift receiver
  I want to open my gift

  Scenario: Opening a Project Gift
    Given I have received a project gift
    When I open the gift
    Then I should see what I have been given
    And I should see a link to the Project

  Scenario: Opening a Gift Card
    Given I have received a gift for $125
    When I open the gift
    Then I should see "Your Gift Card Balance is: $125.00"
    And the gift information should be in the session
    And I should see "find a project to donate to"
    And I should see "let ChristmasFuture figure it out"
    And I should see "Deposit it into my account"
    And I should see "Donate it to ChristmasFuture's Operational budget"
    And I should see "Note: if you choose to do nothing, your gift will expire"

  Scenario: Choosing a gift option
    Given I am opening a gift
    When I go anywhere in the site
    Then I should see my gift card balance

  Scenario: Gift Card Total status
    Given I am opening a gift
    When I follow "find a project to donate to"
    Then I should see my gift card balance in the top right corner

  Scenario: Gift Card Total status - external site
    Given I am opening a gift
    When I go anywhere in the site
    Then there should be a cookie with the Gift Card Balance
    And there should be a cookie with the Gift Card id

  Scenario: Let ChristmasFuture Figure It Out
    Given I have received a gift for $50
    And I open the gift
    When I choose to "let ChristmasFuture figure it out"
    And I press "Yes"
    Then I should be shown my directed order
    And the gift card balance should be $0

  Scenario: Donate it to ChristmasFuture's Operational budget (Admin Gift) 
    Given I have received a gift for $50
    And I open the gift
    When I choose to "Donate it to ChristmasFuture's Operational budget"
    And I press "Yes"
    Then I should be shown my directed order
    And the gift card balance should be $0

  Scenario: Directed Gift
    Given I have received a gift for $50
    And I open the gift
    When I go to a Project Page
    And I follow "Give my entire Gift Card Balance to this project"
    And I press "Yes"
    Then I should be shown my directed order
    And the gift card balance should be $0
