Feature: Gift Editing
	In order to change a gift in my cart
  As a gift sender
  I want to be able to edit a gift

Background:
	Given I am on the new gift page
	And I fill in "gift[name]" with "Mike Richards"
	And I fill in "gift[email]" with "mike.richards@example.com"
	And I fill in "gift[email_confirmation]" with "mike.richards@example.com"
	And I fill in "gift[to_name]" with "Jeff Carter"
	And I fill in "gift[to_email]" with "jcarter@example.com"
	And I fill in "gift[to_email_confirmation]" with "jcarter@example.com"
	And I fill in "Gift Amount" with "5"
	And I choose "Email my gift right away"
	And I press "gift_submit"
  And I follow "Edit" within ".giftcontrols"
	And I fill in "gift[email_confirmation]" with "mike.richards@example.com"
	And I fill in "gift[to_email_confirmation]" with "jcarter@example.com"
   
Scenario: Gift delivery date now
	Given I choose "Email my gift right away"
	And I press "gift_submit"
	Then I should be on my cart page
	And I should see "To: Jeff Carter"
	And the gift should be scheduled for delivery by email
	And the gift should be scheduled for delivery today

Scenario: Gift delivery date now with far future scheduled date
	Given I choose "Email my gift right away"
	And I select a valid future delivery date and time
	And I press "gift_submit"
	Then I should be on my cart page
	And I should see "To: Jeff Carter"
	And the gift should be scheduled for delivery by email
	And the gift should be scheduled for delivery today

Scenario: Gift delivery date in the future
	Given I choose "Schedule my gift delivery"
	And I select a valid future delivery date and time
	And I press "gift_submit"
	Then I should be on my cart page
	And I should see "To: Jeff Carter"
	And the gift should be scheduled for delivery by email
	And the gift should be scheduled for delivery in the future
   
Scenario: Gift delivery date in the past
	Given I choose "Schedule my gift delivery"
	And I select an invalid past delivery date and time
	And I press "gift_submit"
	Then I should see "Send at must be in the future"
   
Scenario: Gift delivery without email
	Given I choose "Don't email my gift"
	And I press "gift_submit"
	Then I should be on my cart page
	And I should see "To: Jeff Carter"
	And the gift should not be scheduled for delivery by email
