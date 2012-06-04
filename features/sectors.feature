Feature: Sectors
  
  Scenario: Sector show page
  Given a sector with projects
  And I am on sector show page
  Then I should see "Demo Sector"
  And I should see "Sector description"
