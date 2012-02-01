class Iend::UsersController < DtApplicationController
  before_filter :restrict_no_user, :only => [ :new, :create ]
  before_filter :restrict_current_user, :only => [ :edit, :update, :edit_password ]
  helper "dt/places"

  helper_method :sector_add, :sector_remove, :sector_params_array

  def index
    @sectors = Sector.alphabetical
    if params[:name].blank? && params[:sectors].blank? && params[:project].blank? && params[:country].blank?
      @profiles = IendProfile.paginate(:page => params[:page], :per_page => 18)
    else
      @profiles = IendProfile.search params[:name],
        :with_all => search_prepare_with_all,
        :without  => search_prepare_without,
        :page     => params[:page],
        :per_page => (params[:per_page].blank? ? 18 : params[:per_page].to_i),
        :order    => (params[:order].blank? ? :created_at : params[:order].to_sym)
    end
    respond_to do |format|
      format.html { render :action => "index", :layout => "iend_users_search"}
    end
  end

  def show
    @user = current_user if params[:id] == 'current'
    @user ||= User.find(params[:id])
    @iend_profile = @user.iend_profile

    @gifts_given_count = @user.gifts.count 
    @gifts_given_amount = @user.gifts.sum(:amount)
    @people_affected = @user.profile.people_impacted.first

    @friends_gifts_given_count = @user.friends_gifts_given_count + @gifts_given_count
    @friends_gifts_given_amount = @user.friends_order_sum + @gifts_given_amount
    @friends_people_affected = @user.friends_projects_lives_affected + @people_affected

    @uend_gifts_given_count = Gift.count + Investment.count
    @uend_gifts_given_amount = Order.complete.sum(:total)
    @uend_people_affected = Project.current.all(:conditions => "lives_affected IS NOT NULL", :select => 'DISTINCT(place_id), lives_affected', :order => "lives_affected DESC").sum(&:lives_affected) + Order.count

    raise ActiveRecord::RecordNotFound if !@iend_profile && @user != current_user
  end

  def new
    @user = User.new
    if session[:omniauth]
      @user.apply_omniauth(session[:omniauth])
      @user.valid?
      render :action => 'new_via_authentication' and return
    end
  end

  def create
    @user = User.new(params[:user])
    @user.apply_omniauth(session[:omniauth]) if session[:omniauth]
    @saved = @user.save
    respond_to do |format|
      if @saved
        session[:omniauth] = nil
        session[:tmp_user] = @user.id
        self.current_user = @user
        flash[:notice] = "Signed in successfully."
        format.html { redirect_to(iend_path) }
      else
        format.html { render :action => (session[:omniauth] ? 'new_via_authentication' : 'new') }
      end
    end
  end

  def edit
    @user = current_user if params[:id] == 'current'
    @user ||= User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:current_password].present?
      params[:user][:password] = nil unless current_user.authenticated?(params[:user][:current_password])
    else
      params[:user][:password] = nil unless params[:user][:current_password].present?
    end
    @user.change_password = false
    @saved = @user.update_attributes(params[:user])
    respond_to do |format|
      if @saved
        flash[:notice] = if params[:user][:current_user].present?
          'Your new password was saved.'
        else
          'Your account was successfully updated.'
        end
        format.html { redirect_to [:iend, current_user] }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def edit_password
    @user = current_user if params[:id] == 'current'
    @user ||= User.find(params[:id])
  end

  protected
    def restrict_no_user
      redirect_to([:iend, current_user]) if logged_in?
    end

    def restrict_current_user
      redirect_to(logged_in? ? iend_user_path(current_user) : iend_path) unless params[:id] == 'current' || params[:id].to_i == current_user.id
    end

    def search_prepare_without
      without = {}
      without.merge!({ :preferred_poverty_sectors => false }) unless sector_params_array.nil? || sector_params_array.empty?
      without.merge!({ :public_name => false }) if params[:name].present?
      without.merge!({ :list_projects_funded => false }) if params[:project].present?
      without.merge!({ :location => false }) if params[:country].present?
      without
    end

    def search_prepare_with_all
      with = {}
      with.merge!({ :sector_ids => sector_params_array }) unless sector_params_array.empty?
      with.merge!({ :funded_project_ids => params[:project] }) unless params[:project].nil?
      with.merge!({ :funded_country_ids => params[:country] }) unless params[:country].nil?
      with
    end

    def sector_params_array
      params[:sectors].try(:split, /\s|\+|,/).to_a
    end

    def sector_add(sector_id)
      sector_params_array.push(sector_id.to_s).uniq.join(' ')
    end

    def sector_remove(sector_id)
      sector_params_array.reject{|a| a == sector_id.to_s}.join(' ')
    end

end
