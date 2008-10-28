class Program < ActiveRecord::Base
  generator_for :name, :start => 'Program' do |prev|
    prev.succ
  end
  generator_for :contact do
    Contact.generate
  end
end