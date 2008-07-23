class Dt::TeamsController < DtApplicationController
  
  before_filter :find_campaign
  before_filter :find_team, :only => [:show, :edit, :update, :destroy, :join, :activate]
  
  # GET /dt_teams
  # GET /dt_teams.xml
  def index
    @teams = Team.find_all_by_campaign_id(params[:campaign_id])
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dt_teams }
    end
  end

  # GET /dt_teams/1
  # GET /dt_teams/1.xml
  def show
  end

  # GET /dt_teams/new
  # GET /dt_teams/new.xml
  def new
    @team = Team.new
    if @campaign.pending?
      flash[:notice] = "This campaign is still pending, and thus cannot be joined."
      redirect_to dt_campaign_path(@campaign)
    end
  end

  # GET /dt_teams/1/edit
  def edit
  end

  # POST /dt_teams
  # POST /dt_teams.xml
  def create
    @team = Team.new(params[:team])
    @team.campaign_id = params[:campaign_id]
    @team.leader = current_user

    respond_to do |format|
      if @team.save
        if @team.pending
          flash[:notice] = 'Team was successfully created, you will be contacted once it has been approved.'
        else
          flash[:notice] = 'Team was successfully created.'
        end
        format.html { redirect_to(dt_team_path(@team)) }
        format.xml  { render :xml => @team, :status => :created, :location => @team }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /dt_teams/1
  # PUT /dt_teams/1.xml
  def update
    respond_to do |format|
      if @team.update_attributes(params[:team])
        flash[:notice] = 'Dt::Team was successfully updated.'
        format.html { redirect_to(@team) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /dt_teams/1
  # DELETE /dt_teams/1.xml
  def destroy
    @team.destroy
    respond_to do |format|
      format.html { redirect_to(dt_teams_url) }
      format.xml  { head :ok }
    end
  end
  
  def manage
    @pending_teams = Team.find_all_by_pending(true)
    @active_teams = Team.find_all_by_pending(false)
  end
  
  def join
    if @team.pending?
      flash[:notice] = "This team has not yet been approved, thus you may not join it."
    else
      if @team.users.include?(current_user)
        flash[:notice] = "You are already a member of this team!"
      else
        @team_member = TeamMember.new
        @team_member.user = current_user
        @team_member.team = @team
        if @team_member.save
          flash[:notice] = "Welcome to the team!"
          if @team.require_authorization?
            flash[:notice] = flash[:notice] + " You will be contacted when your membership has been approved."
          end
        else 
          flash[:notice] = "There was an error joining this team!"
        end
      end  
    end
    redirect_to dt_team_path(@team)
  end
  
  def activate
    if @team.activate!
      flash[:notice] = "#{@team.name} activated!"
      redirect_to manage_dt_campaign_path(@campaign)
    else
      flash[:notice] = "There was an error activating that team, please try again."
    end
  end
  
  private
  def find_campaign
    @campaign = Campaign.find(params[:campaign_id]) unless params[:campaign_id].blank?
    @campaign = Campaign.find_by_short_name(params[:short_campaign_name]) unless params[:short_campaign_name].blank?
    
    if @campaign == nil
      @campaign = Team.find(params[:id]).campaign
    end
    @campaign
  end
  
  def find_team
    @team = Team.find(params[:id]) unless params[:id].blank?
    @team = Team.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
  end
end
