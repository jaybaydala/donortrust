class Iend::FriendshipsController < ApplicationController
  
  before_filter :login_required

  # Creates a friendship with supplied friend_id
  # If the friendship exists, then resend the email
  def create
    Rails.logger.info "Hack Attack!!!" if current_user.id != params[:user_id]
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
    if current_user.id == params[:user_id]
      friendship = current_user.friendships.find(params[:id])
      friendship.accept
    end
    redirect_to iend_user_path(friendship.friend)
  end

  # Declines a friendship
  def decline
    if current_user.id == params[:user_id]
      friendship = current_user.friendships.find(params[:id])
      friendship.destroy
    end
    redirect_to iend_user_path(current_user)
  end

end
