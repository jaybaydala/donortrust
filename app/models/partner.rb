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

  has_many      :partner_limits
  has_many      :campaigns, :through => :partner_limits

  has_many      :partner_payments, :dependent => :destroy

  validates_presence_of :name
  validates_presence_of :description
  validates_length_of   :name, :maximum => 50
  validates_presence_of :partner_status_id
  #validates_presence_of :partner_type_id
  acts_as_textiled :description, :business_model, :funding_sources, :mission_statement, :philosophy_dev

  named_scope :with_active_projects, lambda {
    {
      :joins => :projects,
      :group => "#{quoted_table_name}.id", 
      :conditions => [
        "#{Project.quoted_table_name}.project_status_id IN (?) AND #{quoted_table_name}.partner_status_id =?", 
        ProjectStatus.public_ids, 
        PartnerStatus.active.id
      ]
    }
  }


  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.partner_status( true )
      me.errors.add :partner_status_id, 'does not exist'
    end
    #unless me.partner_type( true )
    #  me.errors.add :partner_type_id, 'does not exist'
    #end
  end

  def admins
    admins = []
    # only grab users that are in the administrations table,
    # in the future we can just grab the users for the specific partner, if that is working with:
    # "WHERE administrable_type = 'partners' AND administrable_id = self.id"
    users = User.find_by_sql("SELECT u.* from users u inner join administrations a ON u.id = a.user_id")
    first = true;
    users.each do |user|
      if user.administrated_partners.include?(self)
        if !first
          admins << ","
        end
        admins << user.full_name
        first = false;
      end
    end
    return admins
  end

  def admins=(admins)
    remove_all_admins
    users_names = admins.split(",")
    users_names.each do |user_name|
      if ((user = User.find_by_full_name(user_name)) != nil)
        user.administrated_partners << self
      end
    end
  end

  def remove_all_admins
    users = User.find(:all)
    users.each do |user|
      user.administrated_partners.delete(self)
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
    return self.projects.count
  end

  def get_number_of_programs
    return self.programs.count
  end

  def get_total_costs
    self.projects.sum(:total_cost, :conditions => { :project_status_id => ProjectStatus.public_ids } )
  end

  def get_total_raised
    @get_total_raised ||= self.projects(:include => [:investments], :conditions => { :project_status_id => ProjectStatus.public_ids } ).inject(0) do |sum, p| 
      sum+= BigDecimal.new(p.dollars_raised.to_s)
    end
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
