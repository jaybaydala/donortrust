class Gift < ActiveRecord::Base
  generator_for :amount => 100
  generator_for :to_name => 'To Name'
  generator_for :name => 'From Name'
  generator_for :to_email => "to_email@example.com"
  generator_for :email => "from_email@example.com"
  generator_for :sent_at => Time.now
end
