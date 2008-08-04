class Sector < ActiveRecord::Base
  acts_as_paranoid
  
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :causes
  
  has_many :place_sectors
  has_many :places , :through => :place_sectors
  has_many :quick_fact_sectors   
     
  validates_presence_of :name
  validates_uniqueness_of :name

  
  #ultrasphinx indexer
  
  is_indexed :fields => [
    {:field => 'id', :as => 'sector_id'},
    {:field => 'name', :sortable => true}
  ], 
  :include => [
      {   
        :class_name => 'Project',
        :field => 'id',
        :as => 'project_id',
        :association_sql => "left join projects_sectors on sectors.id=projects_sectors.sector_id left join projects on projects.id=projects_sectors.project_id"
      }
    ],
  :conditions => "sectors.deleted_at IS NULL"
  
#  def project_count
#    return projects.count
#  end

end
