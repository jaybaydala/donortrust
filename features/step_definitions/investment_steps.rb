Given /^I have added a \$(\d+) investment to my cart$/ do |amount|
  steps %Q{
    Given I am on the new dt investment page
    And I fill in "Amount" with "#{amount}"
    And I press "Add to Cart"
  }
end

Then /^the investment should have selected sector id$/ do
  assert_equal @sector.id, Cart.last.items.last.item.sector_id
end

Then /^the investment should not have any assigned project$/ do
  assert_equal nil, Cart.last.items.last.item.project_id
end
