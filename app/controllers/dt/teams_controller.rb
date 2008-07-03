class Dt::TeamsController < DtApplicationController
  
  before_filter :find_campaign
  
  # GET /dt_teams
  # GET /dt_teams.xml
  def index
    @teams = Team.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @dt_teams }
    end
  end

  # GET /dt_teams/1
  # GET /dt_teams/1.xml
  def show
    @team = Team.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /dt_teams/new
  # GET /dt_teams/new.xml
  def new
    @team = Dt::Team.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @team }
    end
  end

  # GET /dt_teams/1/edit
  def edit
    @team = Team.find(params[:id])
  end

  # POST /dt_teams
  # POST /dt_teams.xml
  def create
    @team = Team.new(params[:team])

    respond_to do |format|
      if @team.save
        flash[:notice] = 'Dt::Team was successfully created.'
        format.html { redirect_to(@team) }
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
    @team = Team.find(params[:id])

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
    @team = Team.find(params[:id])
    @team.destroy

    respond_to do |format|
      format.html { redirect_to(dt_teams_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  def find_campaign
    @campaign = Campaign.find(params[:campaign_id])
  end
end
