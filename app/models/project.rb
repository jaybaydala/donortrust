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

  include Likeable
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
  has_many :milestones, :order => "target_date ASC", :dependent => :destroy
  has_many :tasks, :through => :milestones
  has_many :project_you_tube_videos, :dependent => :destroy
  has_many :project_flickr_images, :dependent => :destroy
  has_many :financial_sources
  has_many :budget_items
  has_many :collaborating_agencies, :through => :collaborations
  has_many :collaborations
  has_many :ranks
  has_many :investments
  has_many :tips
  has_many :gifts
  has_many :subscriptions
  has_many :key_measures
  has_many :my_wishlists
  has_many :users, :through => :my_wishlists
  has_many :project_pois
  has_many :subscribed_project_pois, :conditions => { :unsubscribed => false }, :class_name => "ProjectPoi"
  has_and_belongs_to_many :groups
  has_and_belongs_to_many :sectors
  has_and_belongs_to_many :causes

  has_and_belongs_to_many :campaigns

  acts_as_textiled :description, :intended_outcome, :meas_eval_plan, :project_in_community

  after_save :check_funded

  named_scope :total_cost_between, lambda {|min, max|
    { :conditions => ["total_cost BETWEEN ? AND ?", min.to_i, max.to_i] }
  }
  #named_scope :find_public, lambda { { :conditions => { :project_status_id => ProjectStatus.public_ids } } }
  named_scope :current, lambda {
    {
      :conditions => [
        "#{Project.quoted_table_name}.project_status_id IN (?) AND #{Project.quoted_table_name}.partner_id IN (?)", 
        ProjectStatus.public_ids, 
        Partner.find(:all, :select => "id", :conditions => ["partner_status_id=?", PartnerStatus.active.id]).map(&:id)
      ]
      
    }
  }

  define_index do
    # fields
    indexes :name, :sortable => true
    indexes description
    indexes note
    
    indexes partner(:name), :as => :partner
    indexes country(:name), :as => :country
    indexes sectors(:name), :as => :sector
    indexes project_status(:name), :as => :project_status

    # attributes
    has :id, :as => :project_id
    has :name, :as => :project_name
    has created_at
    has updated_at
    has sectors(:id),   :as => :sector_ids
    has sectors(:name), :as => :sector_names
    has country(:id),   :as => :country_id
    has country(:name), :as => :country_name
    has country(:name), :as => :country_name_sort
    has partner(:id),   :as => :partner_id
    has partner(:name), :as => :partner_name
    has partner(:name), :as => :partner_name_sort
    has project_status(:id), :as => :project_status_id
    has project_status(:name), :as => :project_status_name
    has "CAST(total_cost AS UNSIGNED)", :type => :integer, :as => :total_cost
    has ca
    has us
    
    # global conditions
    where "`projects`.project_status_id IN (SELECT id FROM project_statuses WHERE name LIKE 'Active' OR name LIKE 'Completed') AND `projects`.deleted_at IS NULL AND `partners`.partner_status_id IN (SELECT `partner_statuses`.id FROM `partner_statuses` WHERE name LIKE 'Active' OR name LIKE 'Archived')"
  end

  # ultrasphinx indexer configuration
  #sphinx
  # is_indexed :fields => [
  #   {:field => 'name', :sortable => true},
  #   {:field => 'id', :as => 'project_id'},
  #   {:field => 'description'},
  #   {:field => 'note'},
  #   {:field =>'intended_outcome'},
  #   {:field => 'meas_eval_plan'},
  #   {:field => 'project_in_community'},
  #   {:field => 'total_cost'},
  #   {:field => 'target_start_date'},
  #   {:field => 'project_status_id'},
  #   {:field => 'created_at'},
  #   {:field => 'continent_id'},
  #   {:field => 'country_id'},
  #   ], 
  #   :delta => true, 
  #   :include => [
  #         {:class_name => 'Place',
  #           :field => 'places.name',
  #           :as => 'place_name',
  #           :association_sql => "LEFT JOIN (places) ON (places.id=projects.place_id)",
  #           :sortable => true
  #          },
  #         {:class_name => 'Place',
  #           :field => 'id',
  #           :as => 'place_id'
  #         },
  #         {
  #           :class_name => 'Place',
  #           :field => 'pl.name',
  #           :as  => 'country_name',
  #           :association_sql => 'LEFT JOIN places pl ON pl.id=projects.country_id'
  #         },
  #         {
  #           :class_name => 'Place',
  #           :field => 'pl2.name',
  #           :as  => 'continent_name',
  #           :association_sql => 'LEFT JOIN places pl2 ON pl2.id=projects.continent_id'
  #         },
  #         {:class_name => 'Partner',
  #           :field => 'partners.name',
  #           :as => 'partner_name',
  #           :association_sql => "LEFT JOIN (partners) ON (partners.id=projects.partner_id)",
  #           :sortable => true
  #         },
  #         {
  #           :class_name => 'Partner',
  #           :field => 'par.id',
  #           :as => 'partner_id',
  #           :association_sql => "LEFT JOIN (partners par) ON (par.id=projects.partner_id)",
  #         },
  #         {
  #           :class_name => 'Cause',
  #           :field => 'id',
  #           :as => 'cause_id',
  #           :association_sql => "LEFT JOIN (causes_projects) ON (causes_projects.project_id=projects.id) LEFT JOIN (causes) ON (causes.id=causes_projects.cause_id)"
  #         },
  #         {
  #           :class_name => 'Sector',
  #           :field => 'sectors.id',
  #           :as => 'sector_id',
  #           :association_sql => "LEFT JOIN (projects_sectors) ON projects_sectors.project_id=projects.id LEFT JOIN sectors ON sectors.id=projects_sectors.sector_id"
  #         },
  #         ],
  #   :conditions => "project_status_id IN (2,4) AND projects.deleted_at IS NULL AND partners.partner_status_id IN (1,3)"

  def startDate
    "#{self.start_date}"
  end

  validates_presence_of :name
  validate :max_number_of_sectors
  #validates_length_of   :name, :maximum => 50

=begin
  validates_presence_of :total_cost
  validates_presence_of :dollars_spent
  validates_presence_of :name
  validates_presence_of :place_id
  validates_presence_of :target_start_date
  validates_presence_of :target_start_date
  validates_uniqueness_of :slug, :allow_nil => true
  validate do |me|
    # In each of the 'unless' conditions, true means that the association is reloaded,
    # if it does not exist, nil is returned
    me.errors.add :program_id, 'does not exist'         unless me.program( true )
    me.errors.add :partner_id, 'does not exist'         unless me.partner( true )
    me.errors.add :project_status_id, 'does not exist'  unless me.project_status( true )
    me.errors.add :place_id, 'does not exist'           unless me.place( true )

    if me.total_cost.to_f != me.get_total_budget
      me.errors.add :total_cost, "has to be same as sum of costs of all budget items, i.e. #{me.get_total_budget}."
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
=end

  class << self
    def for_country(code)
      scope = scoped({})
      scope = scope.conditions "us = true" if code == "US"
      scope = scope.conditions "ca = true" if code == "CA"
      scope
    end

    def rehydrate_from_xml(xml)
      Project.new(Hash.from_xml(xml)['project'])
    end

    def unallocated_project
      @unallocated_project ||= Project.find_by_slug("unallocated")
    end

    def admin_project
      @admin_project ||= Project.find_by_slug("admin")
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
      continent_place_type = PlaceType.continent
      if @continents.nil?
        @continents = []
        Project.find_public.all(:include => :place).each do |project|
          if project.community_id? && project.community
            project.place.ancestors.each do |ancestor|
              @continents << ancestor and break if ancestor.place_type_id == continent_place_type.id && !@continents.include?(ancestor) && ancestor.name != 'North America'
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
        Project.find_public.all(:include => :place).each do |project|
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
      country_place_type = PlaceType.country
      if @countries.nil?
        @countries = []
        Project.find_public.all(:include => :place).each do |project|
          if project.community_id? && project.community
            project.place.ancestors.each do |ancestor|
              @countries << ancestor and break if ancestor.place_type_id == country_place_type.id && !@countries.include?(ancestor) && ancestor.name != 'Canada'
            end
          end
        end
        @countries.sort!{|x,y| x.name <=> y.name}
      end
      @countries
    end

    def project_countries
      if @countries.nil?
        @countries = []
        @countries = Place.find_by_sql(
            "SELECT count(*) as count, p.name as name, p.id as id, p.place_type_id "+
            "FROM (SELECT * FROM partners WHERE partner_status_id=1) pa INNER JOIN projects pr INNER JOIN places p "+
            "ON pa.id = pr.partner_id AND pr.country_id = p.id "+
            "WHERE pr.project_status_id IN (2,4) AND pr.deleted_at is NULL AND pa.id != 4 "+
            "GROUP BY p.id ORDER BY count DESC")
        @countries.sort!{|x,y| x.name <=> y.name}
      end
      @countries
    end

    def causes
      if @causes.nil?
        @causes = []
        Project.find_public.all(:include => :causes).each do |project|
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
        Project.find_public.all(:include => :sectors).each do |project|
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
        Project.find_public.all(:include => :partner, :order => 'partners.name').each do |project|
          @partners << project.partner unless @partners.include?(project.partner)
        end
      end
      @partners
    end


    def featured_projects
      projects = Project.current.all(:conditions => { :featured => true })
      projects = Project.current.all(:limit => 3, :order => 'RAND()') if projects.size == 0
      projects
    end
  end

  def allow_subagreement?
    (approval_status == :approved and not is_subagreement_signed?)
  end

  def approval_status
    if not has_pending?
      :approved
    elsif has_pending? and not pending_project.submitted_at.nil?
      :submitted  # waiting for approval
    elsif has_pending?
      :changed    # waiting for submission
    else
      :unknown
    end
  end

  def registration_fees
    RegistrationFees.find(:all)
  end

  def group_project?(user)
    user.groups.each do |user_group|
      return true if group_ids.include?(user_group.id)
    end
    false
  end

  def fundable?
    started = ProjectStatus.started
    return false if started && self[:project_status_id] != started.id
    return false if current_need <= 0
    return true
  end

  def summarized_description(words = 50)
    return unless self.description?
    if @summarized_description.nil?
      @summarized_description = description(:plain).split($;, words+1)
      if words >= description.split.size
        @summarized_description = @summarized_description.join(' ')
      else
        @summarized_description.pop
        @summarized_description = @summarized_description.join(' ')
        @summarized_description += (@summarized_description[-1,1] == '.' ? '..' : '...') 
      end
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
    milestones.count
  end

  def milestones_count
    Milestone.count
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
    milestones.size unless milestones == nil
  end

  def days_remaining
    result = nil
    result = target_end_date - Date.today if target_end_date != nil
    result = 0 if result == nil || result < 0
    return result
  end

  def community_id
    community.id unless community.nil?
  end

  def community_id?
    community.id? unless community.nil?
  end

  def nation_id
    country_id
  end

  def nation_id?
    @nation ||= nation
    self.nation if !@nation
    return @nation ? @nation.id? : false
  end

  def community
    @community ||= self.place if self.place_id? && self.place && self.place.place_type_id >= PlaceType.community.id
    @community
  end

  def community_project_count
    @community_project_count ||= community.projects.size unless community.nil?
  end

  def nation
    nation_place_type = PlaceType.nation
    if place && place.place_type_id == nation_place_type.id
      place
    else
      country
    end
  end

  #Need to add accounting for funds 3rd Party sources
  def current_need
    BigDecimal.new(self.total_cost.to_s) - BigDecimal.new(self.dollars_raised.to_s)
  end

  def current_need_including(num)
    current_need - BigDecimal.new(num.to_s)
  end

  def dollars_raised
    investments(true).inject(0){|raised, investment| raised += investment.amount }
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
    budget_items(force_reload=true).inject(0) { |sum, i| i.cost.nil? ? sum : sum + i.cost }.to_f
  end

  def self.total_money_raised
    Project.find(:all, :include => [:investments]).inject(0) { |sum, p| sum += BigDecimal.new(p.dollars_raised.to_s) }
  end

  def self.fully_funded(conditions = nil)
    all(:conditions => conditions, :include => [:investments]).select{|project| project.current_need <= 0 }
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

  def self.find_public(*args)
    with_scope :find => { :conditions => { :project_status_id => ProjectStatus.public_ids }} do
      find *args
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

  def send_pois(message)
    subscribed_project_pois.each do |poi|
      DonortrustMailer.deliver_project_poi(poi, message)
    end.length
  end

  protected
    def check_funded
      if self.current_need == 0
        DonortrustMailer.deliver_project_fully_funded(self)
      end
    end

  private
    def max_number_of_sectors
      errors.add_to_base "A project can have a maximum of 3 sectors" if self.sectors.length > 3
    end

end
