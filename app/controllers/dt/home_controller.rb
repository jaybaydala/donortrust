class Dt::HomeController < DtApplicationController

  def index
    render :action => "splash", :layout => "dt_application_nonav"
  end

end
