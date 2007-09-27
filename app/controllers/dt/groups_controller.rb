class Dt::GroupsController < DtApplicationController
  before_filter :login_required

  # GET /groups
  # GET /groups.xml
  def index
    @groups = Group.find :all, :conditions => {:private, 0}

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @group.to_xml }
    end
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1;edit
  def edit
    @group = Group.find(params[:id])
  end

  # POST /groups
  # POST /groups.xml
  

  def create
    @group = Group.new(params[:group])
    group_saved = @group.save
    membership = @group.memberships.build(:user_id => current_user.id, :membership_type => 3) if group_saved
    membership_saved = membership.save if membership

    respond_to do |format|
      if membership_saved
        flash[:notice] = 'Group and membership was successfully created.'
        format.html { redirect_to dt_group_url(@group) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    @group = Group.find(params[:id])

    respond_to do |format|
      if @group.update_attributes(params[:group])
        flash[:notice] = 'Group was successfully updated.'
        format.html { redirect_to dt_group_url(@group) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @group.errors.to_xml }
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to dt_groups_url }
      format.xml  { head :ok }
    end
  end
  
  protected
  def authorized?
    true
  end
end

