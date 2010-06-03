class Sector < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :projects

  has_many :causes
  has_many :quick_fact_sectors

  validates_presence_of :name
  validates_uniqueness_of :name


  #ultrasphinx indexer

  is_indexed :fields => [
    {:field => 'id', :as => 'sector_id'},
    {:field => 'name', :sortable => true}
  ], 
  :delta => true, 
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

  #TODO propose a better way to get sector images
  def image_name
    if self.name=='Education'
      return 'educationOn.png'
    elsif self.name=='Agriculture'
      return 'agricultureOn.png'
    elsif self.name=='Economy'
      return 'economyOn.png'
    elsif self.name=='Water & Sanitation'
      return 'waterOn.png'
    elsif self.name=='Gender Equality'
      return 'genderOn.png'
    elsif self.name=='Community Development'
      return 'communityOn.png'
    elsif self.name=='Health'
      return 'healthOn.png'
    elsif self.name=='Infrastructure'
      return 'housingOn.png'
    elsif self.name=='Power & Energy'
      return 'powerenergy.gif'
    elsif self.name=='Government & Advocacy'
      return 'government.gif'
    elsif self.name=='Food'
      return 'food.gif'
    end
  end

  def projects
    #return Project.find_by_sql("SELECT * FROM `projects` LEFT JOIN causes_projects ON projects.id=causes_projects.project_id LEFT JOIN causes ON causes.id=causes_projects.cause_id  LEFT JOIN sectors ON sectors.id=causes.sector_id  WHERE causes.sector_id=#{self.id} AND projects.project_status_id IN (2,4) AND (projects.deleted_at IS NULL) ")
    #return Project.find_public(:all, :joins => [:causes], :conditions => ["causes.sector_id=#{self.id}"])
    return Project.find_public(:all, :joins => [:sectors], :conditions => ["sectors.id=#{self.id}"])
  end
end
