class PartnerStatus < ActiveRecord::Base
  generator_for :name, :start => 'partner status' do |prev|
    prev.succ
  end
  generator_for :description => "Partner Status Description"
end