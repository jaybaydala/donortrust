Feature: Addition
  In order to avoid silly mistakes
  As a math idiot 
  I want to be told the sum of two numbers

  Scenario: Add two numbers
    Given I have entered 50 into the calculator
    And I have entered 70 into the calculator
    When I press add
    Then the result should be 120 on the screen
    And the result class should be Fixnum

    | input_1 | input_2 | button | output | class  |
    | 20      | 30      | add    | 50     | Fixnum |
    | 2       | 5       | add    | 7      | Fixnum |
    | 0       | 40      | add    | 40     | Fixnum |
