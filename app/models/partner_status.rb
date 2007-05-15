class PartnerStatus < ActiveRecord::Base
  def to_label
    "#{statusType}"
  end
end
