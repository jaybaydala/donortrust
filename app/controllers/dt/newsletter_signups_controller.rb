class Dt::NewsletterSignupsController < DtApplicationController
  def new
    render :action => "new", :layout => ( request.xhr? ? false : "application" )
  end
end