class Iend::FriendshipsController < DtApplicationController

  before_filter :login_required

  # Creates a friendship with supplied friend_id
  # If the friendship exists, then resend the email
  def create
    friendship = current_user.friendships.find(:first, :conditions => ["friend_id = ?", params[:friend_id]])
    friendship ||= current_user.friendships.create(:friend_id => params[:friend_id])
    DonortrustMailer.deliver_friendship_request_email(friendship) if friendship && !friendship.accepted?
    flash[:notice] = "Your friendship request has been sent"
    redirect_to iend_user_path(friendship.friend)
  end

  def destroy
    @friendship = current_user.friendships.find(params[:id]) || current_user.inverse_friendships.find(params[:id])
    @friendship.destroy
    flash[:notice] = "Your friendship with #{@friendship.friend.full_name} has been removed"
    redirect_to iend_user_friends_path(current_user)
  end

  # Accepts a friendship
  def accept
    if friendship = current_user.inverse_friendships.find(params[:id])
      friendship.accept
      flash[:notice] = "You accepted the friendship request"
      redirect_to iend_user_path(friendship.user_id)
    else
      head :ok
    end
  end

  # Declines a friendship
  def decline
    if friendship = current_user.inverse_friendships.find(params[:id])
      friendship.destroy
    end
    flash[:notice] = "You declined the friendship request"
    redirect_to iend_user_path(current_user)
  end

end
