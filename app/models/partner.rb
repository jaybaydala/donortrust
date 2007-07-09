class Partner < ActiveRecord::Base
  belongs_to :partner_status

  acts_as_versioned

#  after_save  :create_partner_history
#  after_save :save_partner_history
  
  belongs_to    :partner_type
  belongs_to    :partner_status
  has_many      :partner_versions
  has_many      :projects
  has_and_belongs_to_many :contacts #is this the right relationship? 
  
  validates_presence_of :name, :partner_status_id, :partner_type_id
  validates_length_of   :name, :maximum => 50
  #validates_length_of   :description, :maximum => 1000
  validates_length_of :description, :within => 0..1000, :too_long => "too long (max 1000)", :too_short => " can't be blank"
  
  def create_partner_history
    if Partner.exists?(self.id)
      @create_partner_history_ph = PartnerHistory.new_audit(Partner.find(self.id))
    end
  end
  
  def save_partner_history
    if (@create_partner_history_ph)
      @create_partner_history_ph.save
      @create_partner_history_ph = nil
    end
  end
  
  #  def save_with_audit
  #    save_result       = false
  #    
  #    if (self.save)
  #      ph                    = PartnerHistory.new_audit(self)
  #      save_result           = ph.save
  #    end
  #    return save_result
  #  end
  
  def self.is_a_partner?(object)
    return object.class.to_s == "Partner"
  end
  
  def total_projects    
    return (self.projects.find(:all)).size
  end
  
  def get_number_of_projects_by_status(status)
    projects = self.projects.find(:all, :conditions => "project_status_id = " + status.to_s )    
    return projects.size unless projects == nil 
  end
  
  def get_number_of_projects(partnerid)
    return Project.find(:all, :conditions => "partner_id = " + partnerid.to_s)    
  end
  
end
