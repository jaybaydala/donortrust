class PlaceType < ActiveRecord::Base
  generator_for :name, :start => 'Place Type' do |prev|
    prev.succ
  end
end