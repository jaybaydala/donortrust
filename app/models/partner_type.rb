class PartnerType < ActiveRecord::Base
  has_many :partners
  validates_length_of :name, :maximum => 50
  validates_presence_of :name
  
  def to_label
    "#{name}"
  end
  
end
