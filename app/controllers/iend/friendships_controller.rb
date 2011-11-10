class Iend::FriendshipsController < ApplicationController

  before_filter :login_required

  # Creates a friendship with supplied friend_id
  # If the friendship exists, then resend the email
  def create
    friendship = current_user.friendships.find(:first, :conditions => ["friend_id = ?", params[:friend_id]])
    if friendship
      DonortrustMailer.deliver_friendship_request_email(friendship) if friendship.accepted?
    else
      friendship = current_user.friendships.create(:friend_id => params[:friend_id])
      DonortrustMailer.deliver_friendship_request_email(friendship)
    end
    redirect_to request.referrer
  end

  # Accepts a friendship
  def accept
    friendship = current_user.friendships.find(params[:id])
    if friendship
      friendship.accept
      redirect_to iend_user_path(friendship.friend)
    else
      head :ok
    end
  end

  # Declines a friendship
  def decline
    friendship = current_user.friendships.find(params[:id])
    friendship.destroy
    redirect_to iend_user_path(current_user)
  end

end
