class PartnerStatus < ActiveRecord::Base

  validates_presence_of :statusType, :description
  validates_length_of :statusType, :maximum => 25
  validates_length_of :description, :maximum => 250
  
  def to_label
    "#{statusType}"
  end
end
