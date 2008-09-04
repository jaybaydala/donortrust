require 'acts_as_paranoid_versioned'
class Partner < ActiveRecord::Base
  acts_as_paranoid_versioned
  acts_as_textiled :description, :business_model, :funding_sources, :mission_statement
  belongs_to    :partner_type
  belongs_to    :partner_status
  has_many      :projects , :dependent => :destroy
  has_many      :programs, :through => :projects
  has_many      :quick_fact_partners , :dependent => :destroy
  has_many      :measures, :dependent => :destroy
  has_many      :contacts

  has_many      :campaign_limits
  has_many      :campaigns, :through => :campaign_limits

  has_many      :partner_payments, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50

  acts_as_textiled :description, :business_model, :funding_sources, :mission_statement, :philosophy_dev

  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.partner_status( true )
      me.errors.add :partner_status_id, 'does not exist'
    end
    unless me.partner_type( true )
      me.errors.add :partner_type_id, 'does not exist'
    end
  end

  def total_projects
    return (self.projects.find(:all)).size
  end

  def get_number_of_projects_by_status(status)
    projects = self.projects.find(:all, :conditions => "project_status_id = " + status.to_s )
    return projects.size unless projects == nil
  end

  def get_number_of_projects
    return Project.find(:all, :conditions => "partner_id = " + id.to_s).size
  end

  def get_number_of_programs
    return Program.find(:all, :conditions => "id = " + id.to_s).size
  end

  def get_total_costs
    projects = Project.find(:all, :conditions => ['partner_id = ? AND project_status_id in (?)', id.to_s, [2,4]])

    total_cost = 0
    projects.each do |project|
      if project.total_cost != nil
         total_cost += project.total_cost
      end
    end
    return total_cost
  end

  def get_total_raised
    projects = Project.find(:all, :conditions => ['partner_id = ? AND project_status_id in (?)', id.to_s, [2,4]])
    total_raised = 0
    projects.each do |project|
      if project.dollars_raised != nil
        total_raised += project.dollars_raised
      end
    end
    return total_raised
  end

  def get_total_percent_raised
    percent_raised = 0
    if get_total_costs > 0 and get_total_raised > 0
      percent_raised = ((get_total_raised / get_total_costs) * 100).floor
    end
    if percent_raised > 100 then percent_raised = 100 end
    return percent_raised
  end

end
