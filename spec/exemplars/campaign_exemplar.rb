class Campaign < ActiveRecord::Base
  generator_for :name, :start => 'Sample Campaign' do |prev|
    prev.succ
  end
  generator_for :description => "Campaign description"
  generator_for :country => "Canada"
  generator_for :province => "AB"
  generator_for :postalcode => "T2Y3N2"
  generator_for :fundraising_goal => "1000"
  generator_for :short_name, :start => 'campaign_short_name' do |prev|
    prev.succ
  end
  generator_for :start_date => Time.now + 1.day
  generator_for :event_date => Time.now + 15.days
  generator_for :raise_funds_till_date => Time.now + 30.days
  generator_for :allocate_funds_by_date => Time.now + 45.days
end