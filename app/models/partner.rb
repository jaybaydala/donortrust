class Partner < ActiveRecord::Base
  belongs_to :PartnerType
  belongs_to :PartnerStatus
end
