Feature: A User can surf through the projects
  So that I can find our information about the projects
  As a User
  I want to be able to browse through the projects
  
  Scenario: Project Index
    Given there are 2 featured projects
    When I visit the projects page
    Then I should see the featured projects
    And I should be able to give to those projects

   Scenario: Project Page
    Given there is a project
    When I visit the project
    Then I should see the project information
    And I should see links to more information
    And I should be able to give to the project
