require 'acts_as_paranoid_versioned'
require 'simile_timeline'
class Project < ActiveRecord::Base
  acts_as_simile_timeline_event(
    :fields => {
      :start       => :startDate,
      :title       => :name,
      :description => :description
    })
  acts_as_paranoid_versioned
 
  belongs_to :project_status
  belongs_to :program
  belongs_to :partner
  belongs_to :place
  belongs_to :contact
  belongs_to :frequency_type
  has_many :milestones, :dependent => :destroy
  has_many :project_you_tube_videos, :dependent => :destroy
  has_many :project_flickr_images, :dependent => :destroy
  has_many :you_tube_videos, :through => :project_you_tube_videos
  has_many :financial_sources
  has_many :budget_items
  has_many :collaborating_agencies
  has_many :ranks
  has_many :investments
  has_many :key_measures
  has_many :wishlists
  has_many :users, :through => :wishlists
  has_many :tasks, :through => :milestones
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :causes
  
 def startDate
  "#{self.start_date}"
  end
 
  validates_presence_of :name
 
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    unless me.program( true )
      me.errors.add :program_id, 'does not exist'
    end
    unless me.partner( true )
      me.errors.add :partner_id, 'does not exist'
    end
    unless me.project_status( true )
      me.errors.add :project_status_id, 'does not exist'
    end
    
    #need to validate the presence of other featured projects
    #  there cannot be more than 5 featured projects
    if me.featured == true
      projects = Project.find :all, :conditions => ["deleted_at is null and featured = 1"]
      if projects.length >= 5
        me.errors.add "There are already 5 featured projects. This project "
      end
    end
  end
  
  def milestone_count
    return milestones.count
  end
  
  def milestones_count
    return Milestone.find(:all).size
  end
  
  def public_groups
    @public_groups ||= groups.find(:all, :conditions => { :private => :false })
  end
  
  def self.total_percent_raised
    percent_raised = 100
    unless self.total_costs == nil or self.total_costs == 0
      percent_raised = self.total_money_raised * 100 / self.total_costs      
      if percent_raised > 100 then percent_raised = 100 end
    end
    percent_raised
  end 
  
  def get_number_of_milestones_by_status(status)
    milestones = self.milestones.find(:all, :conditions => {:milestone_status_id => status.to_s } )
    return milestones.size unless milestones == nil     
  end
  
  def days_remaining
    result = nil
    result = target_end_date - Date.today if target_end_date != nil
    result = 0 if result != nil && result < 0
    return result
  end
  
  def community_id
    self.place_id
  end
  
  def community_id?
    self.place_id?
  end

  def nation_id
    self.nation if !@nation
    return @nation ? @nation.id : nil
  end

  def nation_id?
    self.nation if !@nation
    return @nation ? @nation.id? : false
  end

  def community
    @community = self.place if self.place_id?
  end
  
  def community_project_count
    self.community.projects.size
  end
  
  def nation
    if @nation.nil?
      node = self.community if !node
      return @nation = nil if !node
      node = node.parent while node.parent && node.parent.place_type_id != 2
      @nation = node.parent if node.parent.place_type_id == 2
    end
    @nation
  end
  
  def self.find_public(*args)
    options = extract_options_from_args!(args)
    valid_project_status_ids = [2,4]
    case args.first
      when :first then Project.find_by_project_status_id(valid_project_status_ids, options)
      when :all   then Project.find_all_by_project_status_id(valid_project_status_ids, options)
      else
        if options[:conditions]
          if options[:conditiond].is_a?(Hash)
            options[:conditions][:project_status_id] = valid_project_status_ids
          else
            options[:conditions][0]+=" AND (project_status_id IN (?))"
            options[:conditions] << valid_project_status_ids
          end
        else
          options[:conditions] = { :project_status_id => valid_project_status_ids }
        end
        Project.find(args.first, options)
    end
  end
  
  def current_need
    self.total_cost - self.dollars_raised
  end
  
  def dollars_raised
    raised = 0
    Investment.find(:all, :conditions => {:project_id => self.id} ).each do |investment|
      raised = raised + investment.amount
    end
    raised
  end
   
  def get_percent_raised
    percent_raised = 0
    if self.total_cost > 0 then
      percent_raised = (dollars_raised * 100 / total_cost)
      if percent_raised > 100 then percent_raised = 100 end
    end
    return percent_raised
  end
  
  
  def self.projects_nearing_end(days_until_end)
    @projects = Project.find(:all, :conditions => ["(target_end_date BETWEEN ? AND ?)", Time.now, days_until_end.days.from_now])
  end
  
  def get_all_you_tube_videos
    @you_tube_videos = Array.new
    for project_you_tube_video in self.project_you_tube_videos
      @you_tube_videos.push(project_you_tube_video.you_tube_video)
    end
    @you_tube_videos
  end
  
  def get_total_budget
    total_budget_items_cost = 0.0
    budget_items(force_reload=true).each do |item|
      total_budget_items_cost += item.cost
    end
    total_budget_items_cost
  end
  
  def self.total_money_raised
    total = 0
    Project.find(:all).each do |project|
      total = total + project.dollars_raised
    end
    total
  end
  
  def self.total_costs
    return self.sum(:total_cost)
  end
  
  def self.total_money_spent
    return self.sum(:dollars_spent)
  end
end
