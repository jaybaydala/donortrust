class Cause < ActiveRecord::Base
  acts_as_paranoid

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :cause_limits
  has_many :campaigns, :through => :cause_limit
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :millennium_goals

  belongs_to :sector

  acts_as_textiled :description
  
  #ultrasphinx indexer
  is_indexed :fields => [
    {:field => 'id', :as => 'cause_id'},
    {:field => 'name', :sortable => true},
    {:field => 'sector_id'},
  ], 
  :conditions => "causes.deleted_at IS NULL"
  
  
  def projects
    Project.find_by_sql("
                      SELECT * FROM projects
                      INNER JOIN causes_projects 
                       ON causes_projects.project_id=projects.id 
                      INNER JOIN projects_sectors 
                       ON projects_sectors.project_id=projects.id
                      WHERE
                      projects_sectors.sector_id=#{self.sector_id}
                      AND
                      causes_projects.cause_id=#{self.id}
                      AND 
                      projects.project_status_id IN (2,4) AND projects.deleted_at IS NULL
                      GROUP BY projects.id
                      ")
  end
end
