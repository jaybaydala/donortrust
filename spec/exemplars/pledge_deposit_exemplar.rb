class PledgeDeposit < ActiveRecord::Base
  pledge = Pledge.generate!
  generator_for :pledge => pledge
  generator_for :user_id => User.generate!
  generator_for :campaign_id => pledge.campaign_id
  generator_for :amount => pledge.amount
end