class Participant < ActiveRecord::Base
  generator_for :short_name, :start => "participant_short_name" do |prev|
    prev.succ
  end
  generator_for :goal => 100
  generator_for :campaign => Campaign.generate!
  generator_for :team => Team.generate!
  generator_for :user => User.generate!
end