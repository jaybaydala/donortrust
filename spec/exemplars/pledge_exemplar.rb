class Pledge < ActiveRecord::Base
  generator_for :order_id => Order.generate!
  generator_for :amount => rand(100).to_f
  generator_for :campaign => Campaign.generate!
  generator_for :participant => Participant.generate!
end