Given /^I have added a \$(\d+) gift to my cart$/ do |amount|
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


Given /^I have received a \$(\d+) gift$/ do |amount|
  @user ||= @current_user || User.last
  @gift = Factory(:gift, :amount => amount, :to_email => @user.login, :to_email_confirmation => @user.login)
end

When /^I fill in \"(.*)\" with my gift pickup code$/ do |field_name|
  @gift ||= Gift.last
  When "I fill in \"#{field_name}\" with \"#{@gift.pickup_code}\""
end

Then /^I should have a \$(\d+) gift card balance$/ do |amount|
  Then "I should see \"Gift Card Balance: #{number_to_currency(amount)}\""
end