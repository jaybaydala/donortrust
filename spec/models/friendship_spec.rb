require File.dirname(__FILE__) + '/../spec_helper'

describe Friendship do

  context "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:friend) }
  end

  describe "accept" do
    before(:each) do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      time = Time.now
      Time.stub!(:now).and_return(time)
      @friendship = Factory(:friendship)
    end

    it "should set friendship status to true" do
      @friendship.accept
      @friendship.status.should == true
    end

    it "should notify initiator via email" do
      lambda {
        @friendship.accept
      }.should change(ActionMailer::Base.deliveries, :size)
    end

    it "should notify correct user" do
      @friendship.accept
      mail = ActionMailer::Base.deliveries[0]
      mail.to.include?(@friendship.user.email).should be_true
    end
  end

  describe "accepted?" do
    
    it "should return the status of friendship" do
      friendship = Factory(:friendship)
      friendship.accepted?.should == false
    end
  end
end

