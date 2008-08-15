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
    if self.name=='Education and Extreme Poverty'
      return 'education.gif'
    end
    if self.name=='Agriculture and Extreme Poverty'
      return 'agriculture.gif'
    end
    if self.name=='Economy and Extreme Poverty'
      return 'economy.gif'
    end
    if self.name=='Water & Sanitation and Extreme Poverty'
      return 'watersanitation.gif'
    end
    if self.name=='Gender Equality and Extreme Poverty'
      return 'gender.gif'
    end
    if self.name=='Community Development and Extreme Poverty'
      return 'community.gif'
    end
    if self.name=='Health and Extreme Poverty'
      return 'health.gif'
    end
    if self.name=='Infrastructure and Extreme Poverty'
      return 'housing.gif'
    end
  end

  def projects
    Project.find(:all, :joins => [:sectors], :conditions => ["sector_id=#{self.id} AND projects.project_status_id IN (2,4) AND projects.deleted_at IS NULL"], :group => 'projects.id')
  end
end
