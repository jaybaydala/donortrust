class Dt::StaffController < DtApplicationController
  # before_filter :login_required
  
  def show
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
                    'Social Community Manager']
    @staff = user_titles.inject([]) do |staff, title| 
      user = User.find_by_title_and_staff(title, true)
      staff << { :title => title, :user => user }
    end
    logger.debug(@staff.inspect);
    respond_to do |format|
      format.html { }# index.html.erb
    end
  end
end