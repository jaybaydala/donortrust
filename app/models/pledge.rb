class Pledge < ActiveRecord::Base
  belongs_to :participant
  belongs_to :team
  belongs_to :campaign
end
