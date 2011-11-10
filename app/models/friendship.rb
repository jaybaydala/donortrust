class Friendship < ActiveRecord::Base

  belongs_to :user
  belongs_to :friend, :class_name => 'User' 

  def accept
    update_attributes(:status => true, :accepted_at => Time.now)
    DonortrustMailer.deliver_friendship_acceptance_email(self)
  end

  def accepted?
    status == true
  end

end
