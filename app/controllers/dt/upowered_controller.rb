class Dt::UpoweredController < DtApplicationController
  def show
    @page = Page.find_by_permalink("upowered")
    @page_sidebar = Page.find_by_permalink("upowered_sidebar")
    @statistic_widgets = StatisticWidget.all(:order => :position)
  end
end