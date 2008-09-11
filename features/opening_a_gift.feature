Feature: Opening a Gift
  In order to choose how to allocate the money that was given to me
  As a gift receiver
  I want to be able to open my gift

  Scenario: Opening the gift
    Given that I have received a gift
    When I open the gift
    Then I should see my gift card balance
    And the gift information should be in the session
    And I should see an option to "find a project to donate to"
    And I should see an option to "let CF figure it out"
    And I should see an option to "Deposit it into my account"
    And I should see an option to "Donate it to the CF Operations project"
    And I should see an option to "Do nothing"

  Scenario: Opening the gift
    Given that I have received a project gift
    When I open the gift
    Then I should see what I have been given
    And I should see a link to the Project

  Scenario: Choosing a gift option
    Given that I am opening a gift
    When I choose any of the gift opening options
    Then I should see my gift card balance

  Scenario: Gift Card Total status
    Given That I have opened a gift
    When I go to "/dt"
    Then I should see my gift card total in the top right corner

  Scenario: Gift Card Total status (blog site)
    Given That I have opened a gift
    When I go anywhere in the site
    Then there should be a cookie with the Gift Card Amount
    And there should be a cookie with the Gift Card id
