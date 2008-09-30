class PartnerType < ActiveRecord::Base
  acts_as_paranoid
  has_many :partners

  validates_length_of :name, :maximum => 50
  validates_presence_of :name, :description

  def partner_count
    return partners.count
  end
end
