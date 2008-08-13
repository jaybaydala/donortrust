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
 
  has_one :pending_project
  belongs_to :project_status
  belongs_to :program
  belongs_to :partner
  belongs_to :place
  belongs_to :country, :class_name => "Place"
  belongs_to :continent, :class_name => "Place"
  belongs_to :contact
  belongs_to :frequency_type
  has_many :administrations, :as => :administrable
  has_many :milestones, :dependent => :destroy
  has_many :tasks, :through => :milestones
  has_many :project_you_tube_videos, :dependent => :destroy
  has_many :project_flickr_images, :dependent => :destroy
  has_many :financial_sources
  has_many :budget_items
  has_many :collaborating_agencies
  has_many :ranks
  has_many :investments
  has_many :key_measures
  has_many :my_wishlists
  has_many :users, :through => :my_wishlists
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :causes
  
  acts_as_textiled :description, :intended_outcome, :meas_eval_plan, :project_in_community
  
  # ultrasphinx indexer configuration
  #sphinx
  is_indexed :fields => [
    {:field => 'name', :sortable => true}, 
    {:field => 'description'}, 
    {:field => 'note'}, 
    {:field =>'intended_outcome'}, 
    {:field => 'meas_eval_plan'}, 
    {:field => 'project_in_community'},
    {:field => 'total_cost'},
    {:field => 'target_start_date'},
    {:field => 'project_status_id'},
    {:field => 'created_at'}
    ],
    :include => [
          {:class_name => 'Place', 
            :field => 'places.name', 
            :as => 'place_name', 
            :association_sql => "LEFT JOIN (places) ON (places.id=projects.place_id)",
            :sortable => true
          },
          {:class_name => 'Place', 
            :field => 'id', 
            :as => 'place_id'
          },
          {:class_name => 'Partner', 
            :field => 'partners.name', 
            :as => 'partner_name', 
            :association_sql => "LEFT JOIN (partners) ON (partners.id=projects.partner_id)",
            :sortable => true
          },
          {:class_name => 'Partner', 
            :field => 'id', 
            :as => 'partner_id'
          },
          {   
            :class_name => 'Sector',
            :field => 'id',
            :as => 'sector_id',
            :association_sql => "left join projects_sectors on projects.id=projects_sectors.project_id  left join sectors on sectors.id=projects_sectors.sector_id"
          },
          {
            :association_name => 'causes', 
            :field => 'id', 
            :as => 'cause_id',
            :association_sql => "LEFT JOIN (causes_projects) ON (causes_projects.project_id=projects.id) LEFT JOIN (causes) ON (causes.id=causes_projects.cause_id)"
          }
          ],
    :conditions => "project_status_id IN (2,4) AND projects.deleted_at IS NULL"
  
  def startDate
    "#{self.start_date}"
  end
  
  validates_presence_of :total_cost
  validates_presence_of :dollars_spent
  validates_presence_of :name
  validates_presence_of :place_id
  validates_presence_of :target_start_date  
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
    unless me.place( true )
      me.errors.add :place_id, 'does not exist'
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

 # def validate
 #   errors.add(:place_id, "must be a city/village.") if place && place.place_type_id != 6
 # end

  class << self
    def cf_unallocated_project
      @cf_unallocated_project ||= Project.find(11) if Project.exists?(11)
    end

    def cf_admin_project
      @cf_admin_project ||= Project.find(10) if Project.exists?(10)
    end

    def find_public(*args)
      valid_project_status_ids = [2,4]
      with_scope :find => { :conditions => { :project_status_id => valid_project_status_ids }} do
        find *args
      end
    end
    
    def continents_and_countries
      if @continents_and_countries.nil?
        @continents_and_countries = []
        continents.each do |continent|
          @continents_and_countries << continent
          countries.each do |country|
            @continents_and_countries << country if country.parent_id? && country.parent_id == continent.id
          end
        end
      end
      @continents_and_countries
    end
    
    def continents
      if @continents.nil?
        @continents = []
        Project.find_public(:all, :include => :place).each do |project|
          if project.community_id? && project.community
            project.place.ancestors.each do |ancestor|
              @continents << ancestor and break if ancestor.place_type_id == 1 && !@continents.include?(ancestor) && ancestor.name != 'North America'
            end
          end
        end
        @continents.sort!{|x,y| x.name <=> y.name}
      end
      @continents
    end
    
    def continents_all
      if @continents.nil?
        @continents = []
        Project.find_public(:all, :include => :place).each do |project|
          if project.community_id? && project.community
            project.place.ancestors.each do |ancestor|
              @continents << ancestor and break if ancestor.place_type_id == 1 && !@continents.include?(ancestor)
            end
          end
        end
        @continents.sort!{|x,y| x.name <=> y.name}
      end
      @continents
    end

    def countries
      if @countries.nil?
        @countries = []
        Project.find_public(:all, :include => :place).each do |project|
          if project.community_id? && project.community
            project.place.ancestors.each do |ancestor|
              @countries << ancestor and break if ancestor.place_type_id == 2 && !@countries.include?(ancestor) && ancestor.name != 'Canada'
            end
          end
        end
        @countries.sort!{|x,y| x.name <=> y.name}
      end
      @countries
    end
    
    def causes
      if @causes.nil?
        @causes = []
        Project.find_public(:all, :include => :causes).each do |project|
          project.causes.each do |cause|
            @causes << cause unless @causes.include?(cause)
          end
        end
        @causes.sort!{|x,y| x.name <=> y.name}
      end
      @causes
    end
    
    def sectors
      if @sectors.nil?
        @sectors = []
        Project.find_public(:all, :include => :sectors).each do |project|
          project.sectors.each do |sector|
            @sectors << sector unless @sectors.include?(sector)
          end
        end
        @sectors.sort!{|x,y| x.name <=> y.name}
      end
      @sectors
    end
    
    def partners
      if @partners.nil?
        @partners = []
        Project.find_public(:all, :include => :partner, :order => 'partners.name').each do |project|
          @partners << project.partner unless @partners.include?(project.partner)
        end
      end
      @partners
    end
    
    def featured_projects
      projects = Project.find_public(:all, :conditions => { :featured => 1 })
      projects = Project.find_public(:all, :limit => 3) if projects.size == 0
      projects
    end
  end

  def group_project?(user)
    user.groups.each do |user_group|
      return true if group_ids.include?(user_group.id)
    end
    false
  end
  
  def fundable?
    return false if self[:project_status_id] != 2
    return false if current_need <= 0
    return true
  end
  
  def summarized_description(length = 50)
    return unless self.description?
    if @summarized_description.nil?
      @summarized_description = description(:plain).split($;, length+1)
      @summarized_description.pop
      @summarized_description = @summarized_description.join(' ')
      @summarized_description += (@summarized_description[-1,1] == '.' ? '..' : '...')
    end
    @summarized_description
  end
  
  def publicly_visible?
    #publicly visible by default
    visible = true
    #if there is a pending project, that means that
    #this project is either new and awaiting approval
    #or has been updated and is awaiting approval
    #if it's new and hasn't been approved, don't allow
    #it to be seen on the public site
    #if it's been updated and not yet approved, we're ok
    #to show it because it'll be the old version
    if pending_project && pending_project.is_new
      visible = false
    end
    visible
  end
  
  def modified_and_unapproved?
    pending_project && !pending_project.is_new && !pending_project.rejected && pending_project.rejector.nil? && pending_project.date_rejected.nil? && pending_project.rejection_reason.nil?
  end
  
  def has_pending?
    pending_project  
  end
  
  def new_and_unapproved?
    pending_project && pending_project.is_new && !pending_project.rejected && pending_project.rejector.nil? && pending_project.date_rejected.nil? && pending_project.rejection_reason.nil?
  end
  
  def modified_and_rejected?
    pending_project && !pending_project.is_new && pending_project.rejected && !pending_project.rejector.nil? && !pending_project.date_rejected.nil? && !pending_project.rejection_reason.nil?
  end
  
  def new_and_rejected?
    pending_project && pending_project.is_new && pending_project.rejected && !pending_project.rejector.nil? && !pending_project.date_rejected.nil? && !pending_project.rejection_reason.nil?
  end

  def milestone_count
    return milestones.count
  end
  
  def milestones_count
    return Milestone.find(:all).size
  end
  
  def public_groups
    @public_groups ||= groups.find_all_by_private(false)
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
    result = 0 if result == nil || result < 0
    return result
  end
  
  def community_id
    community.id if community
  end
  
  def community_id?
    community.id? if community
  end

  def nation_id
    @nation ||= nation
    return @nation ? @nation.id : nil
  end

  def nation_id?
    @nation ||= nation
    self.nation if !@nation
    return @nation ? @nation.id? : false
  end

  def community
    @community ||= self.place if self.place_id? && self.place && self.place.place_type_id >= 6
  end
  
  def community_project_count
    @community_project_count ||= community.projects.size if community
  end
  
  def nation
    if place.place_type_id == 2
      place
    else
      country
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
      if item.cost != nil
        total_budget_items_cost += item.cost
      end
    end
    total_budget_items_cost
  end
  
  def self.total_money_raised
    total = 0
    Project.find(:all).each do |project|
      if project.dollars_raised != nil
        total = total + project.dollars_raised
      end
    end
    total
  end
  
  def self.total_costs
    return self.sum(:total_cost)
  end
  
  def self.total_money_spent
    return self.sum(:dollars_spent)
  end

  def save_collaborating_agencies
    collaborating_agencies.each do |c|
      if c.should_destroy_agency?
        c.destroy
      else
        c.save(false)
      end
    end
  end   
  
  def collaborating_agency_attributes=(collaborating_agency_attributes)
    collaborating_agency_attributes.each do |attributes|
      if attributes[:id].blank?
        collaborating_agencies.build(attributes)
      else
        collaborating_agency = collaborating_agencies.detect { |c| c.id == attributes[:id].to_i }
        collaborating_agency.attributes = attributes
      end    
    end
  end
  
  def save_financial_sources
    financial_sources.each do |f|
      if f.should_destroy_source?
        f.destroy
      else
        f.save(false)
      end
    end
  end
  
  def financial_source_attributes=(financial_source_attributes)
    financial_source_attributes.each do |attributes|
      if attributes[:id].blank?
        financial_sources.build(attributes)
      else
        financial_source = financial_sources.detect { |f| f.id == attributes[:id].to_i }
        financial_source.attributes = attributes
      end    
    end
  end
  
  def to_complete_xml
    self.to_xml :include => [:milestones, :tasks, :project_you_tube_videos, 
                              :project_flickr_images, :financial_sources, :budget_items,
                              :collaborating_agencies, :ranks, :investments, :key_measures,
                              :my_wishlists, :users, :groups, :sectors, :causes, :place, 
                              :contact, :frequency_type, :partner, :program, :project_status]
  end 
  
end
