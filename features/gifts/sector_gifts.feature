Feature: Sector Gifts
  As a gift sender
  I want to be able to select a gift from a particular sector

Scenario: Gift with sector_id
  Given a sector with projects
  And I am on sector show page
  And I follow "U:forward - pay it forward as a gift."
  Then I should see "Demo Sector"
	And I fill in "gift[name]" with "Mike Richards"
	And I fill in "gift[email]" with "mike.richards@example.com"
	And I fill in "gift[email_confirmation]" with "mike.richards@example.com"
	And I fill in "gift[to_email]" with "jcarter@example.com"
	And I fill in "gift[to_email_confirmation]" with "jcarter@example.com"
	And I fill in "Gift Amount" with "5"
	Given I choose "Email my gift right away"
	And I press "gift_submit"
	Then I should be on my cart page
	And the gift should have selected sector id
  And the gift should not have any assigned project
