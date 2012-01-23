require File.dirname(__FILE__) + '/../spec_helper'

describe DonortrustMailer do

  before(:each) do  
    @user = Factory(:user)
    ActionMailer::Base.deliveries = []  
  end

  it 'should send some random email' do
    mail = DonortrustMailer.deliver_new_user_notification(@user) 
    ActionMailer::Base.deliveries.size.should == 1  
    mail.body.should =~ /#{@user.login}/
  end

end
