class Dt::FacebookPostsController < ApplicationController
  def create
    @facebook = Facebook.new(current_user)
    begin
      @reply = @facebook.post(params[:facebook])
    rescue
      @reply = false
    end
    respond_to do |format|
      message = @reply ? "Your message has been posted to <a href=\"http://www.facebook.com/\">your facebook account</a>" : "We could not post your message"
      format.html {
        flash[:notice] = message
        redirect_to(params[:return_to] ? params[:return_to] : home_path)
      }
      format.js { flash.now[:notice] = message }
    end
  end
end