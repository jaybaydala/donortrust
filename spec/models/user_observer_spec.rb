require File.dirname(__FILE__) + '/../spec_helper'

describe UserObserver do
  before(:each) do
    @user = mock_model(User)
    @user_observer = UserObserver.instance
  end

  specify "should call DonortrustMailer.deliver_new_user_notification on user creation" do
    DonortrustMailer.should_receive(:deliver_new_user_notification).with(@user)
    @user_observer.after_create(@user)
  end

end
