class Sector < ActiveRecord::Base
  acts_as_paranoid
  has_and_belongs_to_many :projects
  has_many :country_sectors
  has_many :countries, :through => :country_sectors

  validates_presence_of :name, :description
  validates_uniqueness_of :name


  def project_count
    return projects.count
  end

  def country_count
    return countries.count
  end
end
