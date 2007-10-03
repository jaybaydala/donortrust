class Dt::GroupsController < DtApplicationController
  before_filter :login_required, :except => [ :index, :show ]
  def initialize
    @topnav = 'get_involved'
  end

  def index
    @groups = Group.find :all, :conditions => {:private => :false}

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  def show
    @group = Group.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @group.to_xml }
    end
  end

  def new
    @group = Group.new
  end

  def edit
    @group = Group.find(params[:id])
  end

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

