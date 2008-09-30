class Place < ActiveRecord::Base
  generator_for :name, :start => 'Place' do |prev|
    prev.succ
  end
end