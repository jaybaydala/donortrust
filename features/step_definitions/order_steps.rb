Given /^that I have removed the optional donation$/ do
  steps %Q{
    Given I am on the dt cart page
    Then show me the page
    And I follow "Edit" within "#optional_donation"
    And I select "0" from "Your donation"
    And I press "Save"
  }
end

Then /^my order should be complete$/ do
  @order ||= Order.last
  @order.complete.should be_true
end
