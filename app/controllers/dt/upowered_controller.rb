class Dt::UpoweredController < DtApplicationController
  include OrderHelper
  layout "upowered"
  def show
    @project = Project.admin_project
    user_titles = [
                    'Executive Director',
                    'Manager of School Program',
                    'Manager of Operations',
                    'Manager of Web Development',
                    'Director of Brand and Design',
                    'Volunteer Coordinator',
                    'Chartered Accountant',
                    'Partnerships',
                    'Executive Assistant',
                    'Social Community Manager'
                  ]
    @staff = user_titles.inject([]) do |staff, title| 
      user = User.find_by_title_and_staff(title, true)
      staff << { :title => title, :user => user }
    end
    @mosaic_users = Subscription.current.all(:order => 'rand()', :limit => 57, :include => :user, :select => "DISTINCT user_id", :conditions => "user_id IS NOT NULL").map(&:user)
    # respond_to do |format|
    #   format.html { render :action => "show", :layout => "projects" }
    # end
  end

  def new
    @project = Project.admin_project
    find_cart
    @investment = @cart.subscription? ? @cart.subscription.item : Investment.new(:amount => 5)
  end

  def create
    find_cart
    @cart_item = @cart.add_upowered(params[:investment][:amount], current_user)
    redirect_to dt_cart_path
  end
end