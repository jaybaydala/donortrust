Given /^I have added a \$(\d+) investment to my cart$/ do |amount|
  steps %Q{
    Given I am on the new dt investment page
    And I fill in "Amount" with "#{amount}"
    And I press "Add to Cart"
  }
end
