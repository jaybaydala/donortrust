Feature: Basic Campaign Management
As a user
I want to be able to create and update a campaign
So that I can help to end poverty
Through the purchase of gifts and investments

Background:
  Given I am an authenticated user

Scenario: Create a new campaign
  Given I am on the iend campaigns page
  When I follow "Create a new campaign"
  Then I should be on the new iend campaign page
  When I fill in "Campaign Name" with "Test Campaign"
  And I fill in "Description" with "testing this out"
  And I fill in "Url" with "test campaign"
  And I press "Create Campaign"
  Then I should be on the "test-campaign" iend campaign page
  And I should see "Your new campaign was created"

Scenario: Update an existing campaign
  Given I have created a campaign with a url of "my-campaign"
  And I go to the "my-campaign" iend campaign page
  Then I should be on the "my-campaign" iend campaign page
  Then I should see "Edit"
  When I follow "Edit"
  Then I should be on the edit iend campaign page
  Given I fill in "Campaign Name" with "Updated Name"
  And I press "Update Campaign"
  Then I should be on the "my-campaign" iend campaign page
  And I should see "Updated Name"

Scenario: Remove an existing campaign
  Given I have created a campaign with a url of "my-campaign"
  And I am on the "my-campaign" iend campaign page
  Then I should see "Remove"
  When I follow "Remove"
  Then I should be on the iend campaigns page
  And I should see "Your campaign was removed"