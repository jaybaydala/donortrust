class PartnerStatus < ActiveRecord::Base
  acts_as_paranoid
  acts_as_textiled :description
  has_many :partners#, :dependent => :destroy

  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_length_of :name, :maximum => 25

  validates_length_of :description, :maximum => 250

  def self.active
    find(:first, :conditions => ["name LIKE ?", "Active"])
  end

  def partner_count
    return partners.count
  end
end
