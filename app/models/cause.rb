class Cause < ActiveRecord::Base
  acts_as_paranoid

  validates_presence_of :name
  validates_uniqueness_of :name

  has_many :projects
  has_many :cause_limits
  has_many :campaigns, :through => :cause_limit
  has_and_belongs_to_many :millennium_goals

  belongs_to :sector

  acts_as_textiled :description
  
  def projects
    Project.find_by_sql("SELECT * FROM projects 
                        INNER JOIN causes_projects ON causes_projects.project_id=projects.id 
                        INNER JOIN causes ON causes_projects.cause_id=causes.id
                        INNER join sectors ON sectors.id=causes.sector_id
                        WHERE
                        causes.sector_id=#{self.sector_id}
                        AND projects.project_status_id IN (2,4) AND projects.deleted_at IS NULL
                        GROUP BY causes.id
                      ")
  end
end
