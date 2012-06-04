Given /^I have added a \$(\d+) gift to my cart$/ do |amount|
  email = Faker::Internet.email
  to_email = Faker::Internet.email
  steps %Q{
    Given I am on the new dt gift page
    And I fill in "gift_email" with "#{email}"
    And I fill in "gift_email_confirmation" with "#{email}"
    And I fill in "gift_to_email" with "#{to_email}"
    And I fill in "gift_to_email_confirmation" with "#{to_email}"
    And I fill in "gift_amount" with "#{amount}"
    And I fill in "gift_message" with "#{Faker::Lorem.sentence}"
    And I choose "Email my gift right away"
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

Given /^I select a valid future delivery date and time$/ do
  select_datetime('gift_send_at', 10.days.from_now)
end

Given /^I select an invalid past delivery date and time$/ do
  select_datetime('gift_send_at', 3.days.ago)
end

Given /^I select an invalid incomplete delivery date and time$/ do
  select_month('gift_send_at', 3.days.from_now)
end

Then /^the gift should not be scheduled for delivery by email$/ do
  assert !Cart.last.items.last.item.send_email?
end

Then /^the gift should be scheduled for delivery by email$/ do
  assert Cart.last.items.last.item.send_email?
end

Then /^the gift should be scheduled for delivery today$/ do
  assert_equal 0.days.ago.to_date, Cart.last.items.last.item.send_at.to_date
end

Then /^the gift should be scheduled for delivery in the future$/ do
  assert Cart.last.items.last.item.send_at >= 0.days.ago
end

Then /^the gift should have selected sector id$/ do
  assert_equal @sector.id, Cart.last.items.last.item.sector_id
end

Then /^the gift should not have any assigned project$/ do
  assert_equal nil, Cart.last.items.last.item.project_id
end

