class Sector < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :projects

  has_many :causes
  has_many :quick_fact_sectors

  validates_presence_of :name
  validates_uniqueness_of :name

#  def project_count
#    return projects.count
#  end

end
