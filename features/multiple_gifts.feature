Feature: Muptiple Gift Giving
 In order to give to more than one recipient
 As a gift giver
 I want to be able to create multiple gifts more easily

 Scenario: Link to "Bulk Gift Giving" page
   Given that I'm any user
   When I visit "/dt/gifts/new"
   Then I should see "Give more than one gift at once"

