class Team < ActiveRecord::Base
  generator_for :name, :start => 'Sample Team' do |prev|
    prev.succ
  end
  generator_for :short_name, :start => "team_short_name" do |prev|
    prev.succ
  end
  generator_for :description => "Team description"
  generator_for :contact_email => "test@example.com"
  generator_for :goal => 1000
end