class PartnerType < ActiveRecord::Base
  generator_for :name, :start => 'Partner Type' do |prev|
    prev.succ
  end
  generator_for :description => "Partner Type description"

end