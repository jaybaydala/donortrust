class Dt::AuthenticationsController < DtApplicationController
  def index
  end

  def create
    render :text => request.env["rack.auth"]
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    flash[:notice] = "Successfully deleted #{@authentication.provider} authentication."
    @authentication.destroy
    redirect_to root_url
  end

  def failure
    flash[:notice] = "Sorry, we couldn't log you in"
    redirect_to root_url
  end
end