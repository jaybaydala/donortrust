Given /^that I have added a \$(\d+) gift to my cart$/ do |amount|
  email = Faker::Internet.email
  to_email = Faker::Internet.email
  steps %Q{
    Given I am on the new dt gift page
    And I fill in "gift_email" with "#{email}"
    And I fill in "gift_email_confirmation" with "#{email}"
    And I fill in "gift_to_email" with "#{to_email}"
    And I fill in "gift_to_email_confirmation" with "#{to_email}"
    And I fill in "Gift Amount" with "#{amount}"
    And I fill in "Your personal message to the recipient(s):" with "#{Faker::Lorem.sentence}"
    And I press "Add to Cart"
  }
end
