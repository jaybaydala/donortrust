class Dt::UpoweredController < DtApplicationController
  def show
    @page = Page.find_by_permalink("upowered")
    @page_sidebar = Page.find_by_permalink("upowered_sidebar")
    @progress_widgets = StatisticWidget.all(:order => :position, :conditions => ["active=?",true], :limit => 2)
    @statistic_widgets = StatisticWidget.all(:order => :position, :conditions => ["active=? AND id NOT IN(?)", true, @progress_widgets.map(&:id)])
  end
end