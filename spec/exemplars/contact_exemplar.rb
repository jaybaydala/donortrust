class Contact < ActiveRecord::Base
  generator_for :first_name, :start => 'first' do |prev|
    prev.succ
  end
  generator_for :last_name, :start => 'last' do |prev|
    prev.succ
  end
end