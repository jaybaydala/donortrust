class Sector < ActiveRecord::Base
  acts_as_paranoid
  acts_as_tree :order=>"name"
  
  has_and_belongs_to_many :projects
  has_many :place_sectors
  
  has_many :places , :through => :place_sectors
  has_many :quick_fact_sectors   
     
  validates_presence_of :name, :description
  validates_uniqueness_of :name

  def project_count
    return projects.count
  end

end
