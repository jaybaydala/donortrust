class PartnerStatus < ActiveRecord::Base
  has_many :partners#, :dependent => :destroy

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 25

  validates_length_of :description, :maximum => 250


  def partners_count
    return partners.count
  end
end
