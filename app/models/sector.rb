class Sector < ActiveRecord::Base
  acts_as_paranoid

  has_and_belongs_to_many :projects

  has_many :causes
  has_many :quick_fact_sectors
  has_many :preferred_sectors
  has_many :users, :through => :preferred_sectors

  validates_presence_of :name
  validates_uniqueness_of :name

  named_scope :with_active_projects, lambda {
    {
      :joins => :projects, 
      :group => "#{quoted_table_name}.id", 
      :conditions => [
        "projects.project_status_id IN (?) AND projects.partner_id IN (?)", 
        ProjectStatus.public.map(&:id),
        Partner.find(:all, :select => "id", :conditions => ["partner_status_id=?", PartnerStatus.active.id]).map(&:id)
      ]
    }
  }
  named_scope :ordered_desc_by_projects, lambda {
    {
      :select => "#{quoted_table_name}.*, count(projects_sectors.sector_id) as projects_count",
      :order => "projects_count DESC"
    }
  }

  def image_name(size = nil)
    "sector-#{self.name.parameterize}#{size ? '-'+size.to_s : ''}.png"
  end

  def projects
    return Project.find_public(:all, :joins => [:sectors], :conditions => ["sectors.id=#{self.id}"])
  end
end
