class Dt::Groups::WallMessagesController < DtApplicationController
  include GroupPermissions
  helper "dt/groups"
  before_filter :membership_required_if_private_group
  before_filter :membership_required, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :ownership_or_admin_required, :only => [:edit, :update, :destroy]
  
  def index
    @group = Group.find(params[:group_id])
    @wall_messages = @group.wall_messages.paginate(:page => params[:wall_page], :per_page => 25, :order => "created_at DESC")
    @wall_message = GroupWallMessage.new
    
    respond_to do |format|
      format.html
    end
  end

  def show
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.find(params[:id])

    respond_to do |format|
      format.html
    end
  end

  def new
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.build

    respond_to do |format|
      format.html
    end
  end

  def edit
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.find(params[:id])
  end

  def create
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.build(params[:wall_message])
    @wall_message.user = current_user

    respond_to do |format|
      if @wall_message.save
        flash[:notice] = 'Your wall message was successfully created.'
        format.html { redirect_to(dt_group_path(@group)) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  def update
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.find(params[:id])

    respond_to do |format|
      if @wall_message.update_attributes(params[:wall_message])
        flash[:notice] = 'Your wall message was successfully updated.'
        format.html { redirect_to(dt_group_path(@group)) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @group = Group.find(params[:group_id])
    @wall_message = @group.wall_messages.find(params[:id])

    respond_to do |format|
      if @wall_message.destroy
        flash[:notice] = 'Your wall message has been destroyed'
      end
      format.html { redirect_to(dt_group_path(@group)) }
    end
  end
  
  protected
  def ownership_or_admin_required
    group = Group.find(params[:group_id])
    @member = group.memberships.find_by_user_id(current_user.id)
    return true if @member && @member.admin?
    wall_message = group.wall_messages.find(params[:id])
    redirect_to dt_group_path(group) and return false if !logged_in?
    redirect_to dt_group_path(group) and return false if current_user.id != wall_message.user_id
    true
  end
  
end
