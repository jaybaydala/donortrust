class Dt::ProjectsController < DtApplicationController
  include RssParser
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]
  before_filter :search_query
  helper "dt/groups"
  helper_method :search_records
  helper_method :search_query
  helper_method :search_query_only_with_term
  helper_method :search_query_with_term
  helper_method :search_query_with_term_one_option
  helper_method :search_query_without_term
  helper_method :search_query_without_text
  layout "projects"

  @monkey_patch_flag = false

  def index
    if params[:search].blank?
      @projects = Project.current.paginate(:conditions => { :featured => true }, :page => params[:page], :per_page => 18)
      @projects = Project.current.paginate(:limit => 3, :order => 'RAND()', :page => params[:page], :per_page => 18) if @projects.size == 0
      @search_text = ""
    else
      @search_text = params[:search][:search_text].present? ? params[:search][:search_text] : ""
      @projects = Project.search @search_text,
        :with => search_query_prepared,
        :page     => params[:page],
        :per_page => (params[:per_page].blank? ? 18 : params[:per_page].to_i),
        :order    => (params[:order].blank? ? :created_at : params[:order].to_sym),
        :populate => true
    end
    respond_to do |format|
      format.html { render :action => "index", :layout => "project_search"}
    end
  end

  def show
    @project = Project.find_public(params[:id])
    @page_title = @project.name
    @rss_feed = last_rss_entry(@project.rss_url) if @project && @project.rss_url
    @budget_items = @project.budget_items
    @organization = @project.partner
    respond_to do |format|
      format.html
    end
  end

  def details
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    @page_title = "Project Details | #{@project.name}"
    @action_js = "http://simile.mit.edu/timeline/api/timeline-api.js"
    respond_to do |format|
      format.html
    end
  end

  def community
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    @community = @project.community
    return render_404 unless @community
    @page_title = "#{@community.name} | #{@project.name}"

    @mdgs = MillenniumGoal.find(:all)
    @rss_feed = last_rss_entry(@project.community.rss_url) if @project && @project.community.rss_url?
    #@rss_feed.clean! if @rss_feed # sanitize the html
    respond_to do |format|
      format.html
    end
  end

  def nation
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    @nation = @project.nation
    return render_404 unless @nation
    @page_title = "#{@nation.name} | #{@project.name}"
    @mdgs = MillenniumGoal.find(:all)
    respond_to do |format|
      format.html
    end
  end

  def organization
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    @organization = @project.partner if @project.partner_id?
    return render_404 unless @organization
    @page_title = "#{@organization.name} | #{@project.name}"
    respond_to do |format|
      format.html
    end
  end

  def connect
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    @public_groups = @project.public_groups.paginate({:page => params[:page], :per_page => 10})
    @page_title = "Connect | #{@project.name}"

    integrate_facebook
    respond_to do |format|
      format.html
    end
  end

  def cause
    begin
      @project = Project.find_public(params[:id])
      @cause = Cause.find(params[:cause_id]) if params[:cause_id]
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    respond_to do |format|
      format.html {render :action => 'cause', :layout => 'dt/plain'}
    end
  end

  def give
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
    end
    return render_404 unless @project
    respond_to do |format|
      format.html
    end
  end


  def facebook_login
    # placeholder for the before_filters above: project_id_to_session, facebook_login
    # is there a more elegant way to do this?
    # project_id_to_session: stores the project id in the (surprise) session,
    # require_facebook_login is a rfacebook thing that bounces the user to facebook, gets a session id, and stores it in the rails session, makes the fbsession object available to controllers
  end
  def finish_facebook_login
    project_id = session[:project_id]
    session[:project_id] = nil
    respond_to do |format|
      # TODO: translate to the hash format
      # :action => 'connect', :id=>session[:project_id]
      format.html { redirect_to dt_connect_project_path(project_id) }
    end
  end

  def timeline
    @project = Project.find(params[:id])
    return render_404 unless @project
    @milestones = @project.milestones(:include => :tasks)
    @tasks = @project.tasks  #Task.find(:all, :joins=>['INNER Join milestones on tasks.milestone_id = milestones.id'], :conditions=> ['milestones.project_id = ?', @id])
    render :partial => 'timeline'
  end

  def list
    @projects = Project.paginate :page => params[:page]
    render :layout => false
  end

  def get_videos
    begin
      @project = Project.find_public(params[:id])
    rescue ActiveRecord::RecordNotFound
      render_404 and return
    end
    @youtube_videos = @project.project_you_tube_videos
    respond_to do |format|
      format.js {
        render :update do |page|
          if @youtube_videos.size>0
            page.replace_html "project_videos", :partial => 'youtube_video' , :collection => @youtube_videos
          else
            page.replace_html "project_videos", '<h2>There are no project videos available at this time.</h2>'
          end
        end
      }
    end
  end


  protected
    def search_facets
      %w(sector_ids country_id partner_id total_cost project_status_id)
    end

    def search_records
      if @search_records.nil?
        @search_records = {}
        @search_records[:search_text] = [params[:search][:search_text]] if params[:search][:search_text].present?
        search_query.each do |facet, terms|
          facet = facet.to_sym
          case facet
          when :sector_ids
            records = Sector.find(terms)
          when :partner_id
            records = Partner.find(terms)
          when :country_id
            records = Place.find(terms)
          when :total_cost
            records = terms.map{|term| term.split(',') }
          when :project_status_id
            records = ProjectStatus.find(terms)
          end
          @search_records[facet] = records
        end
      end
      @search_records
    end

    def search_query
      search_query = params[:search].present? ? params[:search].dup : {}
      search_facets.each do |term|
        term = term.to_sym
        search_query[term] ||= []
        search_query[term].uniq!
      end
      if search_query[:search_text].present?
        search_query.delete(:search_text)
      end
      if !search_query[:project_status_id].present?
        search_query[:project_status_id] = [ProjectStatus.active.id]
      end
      search_query
    end

    def search_query_prepared
      search_query_prepared = search_query.delete_if{|f,t| t.blank? }
      if search_query_prepared[:total_cost].present?
        total_costs = search_query_prepared[:total_cost].map{|t| t.split(',') }.flatten.map(&:to_i)
        search_query_prepared[:total_cost] = (total_costs.min..total_costs.max)
      end
      if search_query_prepared[:search_text].present?
        search_query_prepared.delete(:search_text)
      end
      search_query_prepared
    end

    def search_query_only_with_term(facet, term)
      { facet.to_sym => [ term ] }
    end

    def search_query_with_term_one_option(facet, term)
      facet        = facet.to_sym
      query        = self.search_query
      query[facet] = [term]
      query.delete_if{ |f,t| t.blank? }
      query
    end

    def search_query_with_term(facet, term, options = {})
      search_options = {:with_text => false}
      search_options.merge! options
      facet = facet.to_sym
      query = self.search_query
      query[facet] << term unless query[facet].include?(term.to_s)
      query.delete_if{|f,t| t.blank? }
      if search_options[:with_text] && params[:search].present? && params[:search][:search_text].present?
        query[:search_text] = params[:search][:search_text]
      end
      query
    end

    def search_query_without_term(facet, term)
      query = self.search_query
      query[facet.to_sym].delete(term.to_s)
      query.delete_if{|f,t| t.blank? }
      query
    end

    def search_query_without_text(facet, term)
      query = self.search_query
      query.delete(facet)
      query.delete_if{|f, t| t.blank?}
      query
    end

    def project_id_to_session
      session[:project_id] = params[:id]
    end

    def integrate_facebook
      if @project.place and @project.place.facebook_group_id?
        @fb_group_available = true
        @facebook_group_link = "http://www.facebook.com/group.php?gid=#{@project.place.facebook_group_id}"
        if fbsession and fbsession.is_valid?:
          gid = @project.place.facebook_group_id
          @fbid = fbsession.users_getLoggedInUser()
          begin
            @fb_group = fbsession.groups_get(:gids=>gid)
            @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
            members_results = fbsession.groups_getMembers(:gid=>gid)
            # weird! api seems to have bug: cannot do member.uid from group results, have to jump thru hoops
            member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
            members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
            @fb_members = members.paginate({:page => params[:fb_page], :per_page => 24})
            @fb_user_in_group = true if member_ids.find{ |id| Integer(@fbid.to_s)==id}
          rescue
            @fb_group_available = false
          end
        end
      end
    end
end
