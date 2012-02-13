Feature: ProjectPoi Unsubscribe
  When a user unsubscribes
  They should go to the unsubscribe link with a token
  And should have a flash message saying whether unsubscribe worked or not
  And should not get any more project poi emails from that project poi's project

  Scenario: Unsubscribe works
    Given I have a project poi with token 12345
    And I go to the unsubscribe project poi by token 12345 page
    Then I should see "You have been unsubscribed"
    And the project poi with token 12345 should be unsubscribed
