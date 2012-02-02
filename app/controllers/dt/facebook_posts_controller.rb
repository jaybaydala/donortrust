class Dt::FacebookPostsController < DtApplicationController
  def create
    @facebook = Facebook.new(current_user)
    begin
      @response = @facebook.post(params[:facebook])
    rescue
      Rails.logger.info "** FACEBOOK ERROR **"
      Rails.logger.info $!.class.inspect
      Rails.logger.info $!.inspect
      @response = false
    end
    respond_to do |format|
      message = @response ? "Your message has been posted to <a href=\"http://www.facebook.com/\">your facebook account</a>" : "We could not post your message"
      format.html {
        flash[:notice] = message
        redirect_to(params[:return_to] ? params[:return_to] : home_path)
      }
      format.js { flash.now[:notice] = message }
    end
  end
end