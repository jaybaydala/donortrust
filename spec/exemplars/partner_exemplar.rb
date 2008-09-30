class Partner < ActiveRecord::Base
  generator_for :name, :start => 'donortrust partner' do |prev|
    prev.succ
  end
  generator_for :description => "Partner description"
  generator_for :partner_status do
    PartnerStatus.generate
  end
end