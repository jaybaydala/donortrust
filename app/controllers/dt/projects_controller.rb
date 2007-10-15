class Dt::ProjectsController < DtApplicationController
  before_filter :project_id_to_session, :only=>[:facebook_login]
  before_filter :require_facebook_login, :only=>[:facebook_login]

  def initialize
    @topnav = 'projects'
  end
  
  def index
    @projects = Project.find(:all, :conditions => { :featured => 1 })
    # TODO: Project should be order_by Rating once rating model is done
    @projects = Project.find(:all, :limit => 3) if @projects.size == 0
    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def show
    @project = Project.find(params[:id])
    respond_to do |format|
      format.html # show.rhtml
    end
  end

  def specs
    @project = Project.find(params[:id])
  end

  def village
    @project = Project.find(params[:id])
    @village = @project.village
  end
    
  def nation
    @project = Project.find(params[:id])
    @nation = @project.nation
  end
    
  def community
    @project = Project.find(params[:id])

    #facebook stuff
    #gid = @project.place.facebook_group_id
    if @project.place and @project.place.facebook_group_id
      @group_available = true
    end
    if fbsession and fbsession.is_valid?:
      #gid = 3362029547
      gid = @project.place.facebook_group_id
      @fbid = fbsession.users_getLoggedInUser()
      @group = fbsession.groups_get(:gids=>gid)
      @fb_user = fbsession.users_getInfo(:uids=>@fbid, :fields=>["name"]).user_list[0]
      members_results = fbsession.groups_getMembers(:gid=>gid)
      # wierd! api seems to have bug: cannot do member.uid, have to jump thru hoops
      member_ids = members_results.search("//uid").map{|uidNode| uidNode.inner_html.to_i}
      @members = fbsession.users_getInfo(:uids=>member_ids, :fields=>["name","pic_square", "pic", "pic_small"]).user_list
      @fb_user_in_group = true if @members.include?(@fbid)
    end
  end

  def facebook_login
    # placeholder for the before_filters above: project_id_to_session, facebook_login
    # is there a more elegant way to do this? 
    # stores the project id, so that when the user returns from facebook, they will right back
    # to the community before the bounce
    # require_facebook_login is a rfacebook thing that bounces the user to facebook
  end
  def finish_facebook_login
    # redirect here
    project_id = session[:project_id]
    session[:project_id] = nil
    respond_to do |format|
      format.html { redirect_to :action => 'community', :id=>session[:project_id] }
    end
  end

  def project_id_to_session
    puts session[:project_id]
    session[:project_id] = params[:id]
    puts session[:project_id]
  end

end
