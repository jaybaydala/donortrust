Given /^I have a current \$(\d+) UPowered subscription added on ([^$]+)$/ do |amount, date|
  @subscription = Factory(:subscription, { :amount => amount, :begin_date => date.to_date })
  @subscription_line_item = Factory(:subscription_line_item, { :subscription => @subscription, :item_type => "Investment", :item_attributes => Factory.build(:investment, :amount => amount, :project => Project.admin_project).attributes })
end

Given /^all of my subscriptions have run successfully$/ do
  @subscription ||= Subscription.last
  current_date = @subscription.begin_date
  while current_date < Date.today
    Timecop.travel(current_date) do
      order = @subscription.prepare_order
      @subscription.line_items.each do |line_item|
        item = line_item.item
        item.order_id = order.id
        item.save!
      end
      order.update_attributes(:complete => true)
    end
    current_date += 1.month
  end
end

Given /^my|the subscription credit card expiry date is (\d\d)\/(\d\d\d\d)$/ do |month, year|
  @subscription.update_attributes(:expiry_month => month.to_i, :expiry_year => year.to_i)
end

When /^the system checks for impending subscription credit card expirations$/ do
  Subscription.notify_impending_card_expirations
end

When /^the system generates my UPowered tax receipt$/ do
  @tax_receipt = @subscription.create_yearly_tax_receipt
end

Then /^the UPowered tax receipt should total \$(\d+)$/ do |arg1|
  @tax_receipt.total.should == 60
end

Then /^the subscriber should receive an email$/ do
  @subscription ||= Subscription.last
  Then "\"#{@subscription.email}\" should receive an email"
end