When /^I create a new campaign$/ do
  steps %Q{
    Given I am on the new dt campaign page
    Then show me the page
    When I fill in the following:
      | Name             | My cool new campaign       |
      | Short Name       | coolcampaign1              |
      | Contact Email    | test@example.com           |
      | Description      | Lorem ipsum dolor sit amet |
      | Fundraising Goal | 1000                       |
      | Address          | 36 Munroe Cres             |
      | City             | Calgary                    |
      | Postal Code      | T2Y 3N2                    |
    And I select "Traditional" from "Campaign type"
    And I select "Alberta" from "Province"
    And I select "Canada" from "Country"
    And I select "2020-May-7 18:00" as the "Event Date:" date and time
    And I select "2020-May-7 18:00" as the "Raise Funds Till:" date and time
    And I select "2020-August-7 18:00" as the "Allocate Funds By:" date and time
  }
end
