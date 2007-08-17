class Country < ActiveRecord::Base
  belongs_to :continent
  has_many :regions, :dependent => :destroy
  has_many :country_sectors
  has_many :sectors, :through => :country_sectors

  validates_presence_of :name
  validates_uniqueness_of :name

  def to_label  
    "#{name}"
  end
end
