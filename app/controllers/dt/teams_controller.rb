class Dt::TeamsController < DtApplicationController
  
  before_filter :find_campaign
  before_filter :find_team, :only => [:show, :edit, :update, :destroy]
  
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
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
    @team.author = current_user

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Dt::Team was successfully created.'
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
