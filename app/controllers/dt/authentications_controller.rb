class Dt::AuthenticationsController < DtApplicationController
  def index
    @authentications = current_user.authentications if current_user
  end

  def create
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Signed in successfully."
      current_user = authentication.user
      redirect_to current_user
    elsif current_user
      current_user.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'])
      flash[:notice] = "Authentication successful."
      redirect_to authentications_url
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Signed in successfully."
        current_user = user
        redirect_to current_user
      else
        session[:omniauth] = omniauth
        redirect_to new_account_url
      end
    end
  end

  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
    flash[:notice] = "Successfully deleted #{@authentication.provider} authentication."
    redirect_to authentications_url
  end

  def failure
    flash[:notice] = "Sorry, we couldn't log you in"
    redirect_to root_url
  end
end