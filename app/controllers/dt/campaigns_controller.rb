class Dt::CampaignsController < DtApplicationController
  
  before_filter :login_required, :only => [:create, :new, :edit, :destroy]
  
  # GET /campaigns
  # GET /campaigns.xml
  def index
    @campaigns = Campaign.find_all_by_pending(false)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @campaigns }
    end
  end

  # GET /campaigns/1
  # GET /campaigns/1.xml
  def show
    @campaign = Campaign.find(params[:id]) unless params[:id].blank?
    @campaign = Campaign.find_by_short_name(params[:short_name]) unless params[:short_name].blank?
    [@campaign, @wall_post = @campaign.wall_posts.new]
    if @campaign != nil
      return @campaign
    else
      redirect_to :controller => 'campaigns', :action => 'index'
    end
  end
  
  # GET /campaigns/new
  # GET /campaigns/new.xml
  def new
    @campaign = Campaign.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @campaign }
    end
  end

  # GET /campaigns/1/edit
  def edit
    @campaign = Campaign.find(params[:id])
  end

  # POST /campaigns
  # POST /campaigns.xml
  def create
    @campaign = Campaign.new(params[:campaign])
    @campaign.campaign_type_id = params[:campaign_type][:id]
    @campaign.creator = current_user
    
    respond_to do |format|
      if @campaign.save
        flash[:notice] = '	Campaign was successfully created.'
        format.html { redirect_to(configure_filters_for_dt_campaign_path(@campaign)) }
        format.xml  { render :xml => @campaign, :status => :created, :location => @campaign }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /campaigns/1
  # PUT /campaigns/1.xml
  def update
    @campaign = Campaign.find(params[:id])

    respond_to do |format|
      if @campaign.update_attributes(params[:campaign])
        flash[:notice] = 'Campaign was successfully updated.'
        format.html { redirect_to(@campaign) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @campaign.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /campaigns/1
  # DELETE /campaigns/1.xml
  def destroy
    @campaign = Campaign.find(params[:id])
    @campaign.destroy

    respond_to do |format|
      format.html { redirect_to(	campaigns_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def admin
    @pending_campaigns = Campaign.find_all_by_pending(true)
    @active_campaigns = Campaign.find_all_by_pending(false)
    [@pending_campaigns, @active_camapaigns]
  end
  
  def main_page
    @campaign = Campaign.find_by_short_name(params[:short_name])
  end

  def activate
    @campaign = Campaign.find(params[:id])
    
    if @campaign.activate!
      flash[:notice] = "Campaign Sucessfully Activated"
    else
      flash[:error] = "Campaign Not Activated"
    end
   
    [@pending_campaigns = Campaign.find_all_by_pending(true), @active_campaigns = Campaign.find_all_by_pending(false)]
    render :layout => false
  end

  def manage
    @campaign = Campaign.find(params[:id])
  end
  
  def configure_filters_for
    @campaign = Campaign.find(params[:id])
    if(params[:project_page] != nil)
      @projects = Project.paginate :page => params[:project_page], :per_page => 10
      render :partial => 'configure_project_filters'
    end
    if(params[:cause_page] != nil)
      @causes = Cause.paginate :page => params[:cause_page], :per_page => 10
      render :partial => 'configure_cause_filters'
    end
    if(params[:parner_page] != nil)
      @causes = Partner.paginate :page => params[:partner_page], :per_page => 10
      render :partial => 'configure_partner_filters'
    end
  end
  
  def add_project_limit_to
      @project_limit = ProjectLimit.create :project_id => params[:project_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @project_limit.errors, @current_panel = 'project']
      render :partial => 'project_filters'
  end
  
  def remove_project_limit_from
      @project_limit = ProjectLimit.find(params[:id])
      @campaign = Campaign.find(@project_limit.campaign_id)
      @project_limit.destroy
      [@campaign, @current_panel = 'project']
      render :partial => 'project_filters'
  end
  
  def add_cause_limit_to
      @cause_limit = CauseLimit.create :cause_id => params[:cause_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @cause_limit.errors, @current_panel = 'cause']
      render :partial => 'project_filters'
  end
  
  def remove_cause_limit_from
      @cause_limit = CauseLimit.find(params[:id])
      @campaign = Campaign.find(@cause_limit.campaign_id)
      @cause_limit.destroy
      [@campaign, @current_panel = 'cause']
      render :partial => 'project_filters'
  end
  
  def add_place_limit_to
      @place_limit = PlaceLimit.create :place_id => params[:place_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @place_limit.errors, @current_panel = 'place']
      render :partial => 'project_filters'
  end
  
  def remove_place_limit_from
      @place_limit = PlaceLimit.find(params[:id])
      @campaign = Campaign.find(@place_limit.campaign_id)
      @place_limit.destroy
      [@campaign, @current_panel = 'place']
      render :partial => 'project_filters'
  end
  
  def add_partner_limit_to
      @partner_limit = PartnerLimit.create :partner_id => params[:partner_id], :campaign_id => params[:id]
      [@campaign = Campaign.find(params[:id]), @errors = @partner_limit.errors, @current_panel = 'partner']
      render :partial => 'project_filters'
  end
  
  def remove_partner_limit_from
      @partner_limit = PartnerLimit.find(params[:id])
      @campaign = Campaign.find(@partner_limit.campaign_id)
      @partner_limit.destroy
      [@campaign, @current_panel = 'partner']
      render :partial => 'project_filters'
  end
  
  def validate_short_name_of
    @errors = Array.new
    
    @short_name = params[:campaign_short_name]
    if @short_name != nil 
      @short_name.downcase!
      
      if(@short_name =~ /\W/)
        @errors.push('You may only use Alphanumeric Characters, hyphens, and underscores. This also means no spaces.')
      end
    
      if(@short_name.length < 3 and @short_name.length != 0)
        @errors.push('The short name must be 3 characters or longer.')
      end
    
      if(Campaign.find_by_short_name(@short_name) != nil)
        @errors.push('That short name has already been used, short names must be globally unique.')
      end
    else 
      @errors.push('The short name may not contain any reserved characters such as ?')
    end
    puts @errors
    [@errors, @short_name]
  end
end