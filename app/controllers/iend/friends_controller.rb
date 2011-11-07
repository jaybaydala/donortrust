class Iend::FriendsController < ApplicationController
  
  before_filter :login_required

  def index
    @user = User.find(params[:user_id])
    @friends = @user.friends + @user.inverse_friends
  end

end
