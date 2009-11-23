class Dt::UpoweredController < DtApplicationController
  before_filter :store_location
  include RssParser
  def show
    @page = Page.find_by_permalink("upowered")
    # @page_sidebar = Page.find_by_permalink("upowered_sidebar")
    @rss_sidebar = last_rss_entry("http://upowered.uend.tag.ca/?feed=rss2")
    @progress_widgets = StatisticWidget.all(:order => :position, :conditions => ["active=?",true], :limit => 2)
    @statistic_widgets = StatisticWidget.all(:order => :position, :conditions => ["active=? AND id NOT IN(?)", true, @progress_widgets.map(&:id)])
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
      @mosaic_users = Subscription.all(:order => 'rand()', :limit => 57, :include => :user, :conditions => "user_id IS NOT NULL").map(&:user)
  end
end