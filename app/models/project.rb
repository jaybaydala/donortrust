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
  
  def startDate
    "#{self.start_date}"
  end
 
 # validates_presence_of :name
 #validates_presence_of :place_id
 # validates_presence_of :target_start_date  
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
 #   unless me.program( true )
 #     me.errors.add :program_id, 'does not exist'
 #   end
#    unless me.partner( true )
 #     me.errors.add :partner_id, 'does not exist'
 #   end
 #   unless me.project_status( true )
 #     me.errors.add :project_status_id, 'does not exist'
 #   end
 #   unless me.place( true )
 #     me.errors.add :place_id, 'does not exist'
 #   end
    
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
      options = extract_options_from_args!(args)
      valid_project_status_ids = [2,4]
      if !options[:conditions].nil?
        if options[:conditions].is_a?(Hash)
          options[:conditions][:project_status_id] = valid_project_status_ids
        elsif options[:conditions].is_a?(Array)
          options[:conditions][0] += " AND (project_status_id IN (?))"
          options[:conditions] << valid_project_status_ids
        else
          options[:conditions] += " AND (project_status_id IN (#{valid_project_status_ids.join(',')}))"
        end
      else
        options[:conditions] = { :project_status_id => valid_project_status_ids }
      end
      Project.find(args.first, options)
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
    
    def partners
      if @partners.nil?
        @partners = []
        Project.find_public(:all, :include => :partner, :order => 'partners.name').each do |project|
          @partners << project.partner unless @partners.include?(project.partner)
        end
      end
      @partners
    end
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
    @community = self.place if self.place_id? && self.place && self.place.place_type_id >= 6
  end
  
  def community_project_count
    self.community.projects.size
  end
  
  def nation
    if @nation.nil? && place_id? && place
      return place if place.place_type_id == 2
      place.ancestors.reverse.each do |ancestor|
        return ancestor if ancestor.place_type_id? && ancestor.place_type_id == 2
      end
    end
    @nation
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
end
