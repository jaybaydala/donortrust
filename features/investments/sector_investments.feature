Feature: Sector Investments
  As a user
  I want to be able to invest to a project from a particular sector

Scenario: Investment with sector_id
  Given a sector with projects
  And I am on sector show page
  And I follow "U:direct - Give directly to this sector."
  Then I should see "Demo Sector"
	And I fill in "Investment Amount" with "5"
	And I press "investment_submit"
	Then I should be on my cart page
	And the investment should have selected sector id
  And the investment should not have any assigned project
