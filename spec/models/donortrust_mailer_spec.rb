require File.dirname(__FILE__) + '/../spec_helper'

describe DonortrustMailer do
  def parse_email(email)
    TMail::Address.parse(email)
  end

  before do
    @user = Factory(:user)
    @project = Factory(:project)
  end

  describe "wishlist email" do
    before do
      @share = Factory(:share, :user => @user)
    end

    it "should set the from" do
      @email = DonortrustMailer.create_wishlist_mail(@share, [ @project.id ])
      @email.from_addrs.first.name.should == "#{@share.name} via UEnd"
      @email.from_addrs.first.address.should == "info@uend.org"
    end
  end

  describe "invitation email" do
    before do
      @group = Factory(:group)
      Factory(:membership, :user => @user, :group => @group)
      @invitation = Factory(:invitation, :user => @user, :group => @group)
    end

    it "should set the from" do
      @email = DonortrustMailer.create_invitation_mail(@invitation)
      @email.from_addrs.first.name.should == "#{@user.full_name} via UEnd"
      @email.from_addrs.first.address.should == @user.email
    end
  end

  describe "share email" do
    before do
      @share = Factory(:share, :user => @user)
    end

    it "should set the from" do
      @email = DonortrustMailer.create_share_mail(@share)
      @email.from_addrs.first.name.should == "#{@user.full_name} via UEnd"
      @email.from_addrs.first.address.should == "info@uend.org"
    end
  end

  describe "gift" do
    before do
      @gift = Factory(:gift, :user => @user)
    end

    describe "gift email" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_mail(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "gift confirm" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_confirm(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "gift notify" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_notify(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "gift resendPDF" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_resendPDF(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "gift expiry notifier" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_expiry_notifier(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "gift expiry reminder" do
      it "should set the from" do
        @email = DonortrustMailer.create_gift_expiry_reminder(@gift)
        @email.from_addrs.first.name.should == "#{@gift.name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

  end

  describe "friendship" do
    before do
      @friendship = Factory(:friendship, :user => @user)
    end

    describe "request email" do
      it "should set the from" do
        @email = DonortrustMailer.create_friendship_request_email(@friendship)
        @email.from_addrs.first.name.should == "#{@friendship.user.full_name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end

    describe "acceptance email" do
      it "should set the from" do
        @email = DonortrustMailer.create_friendship_request_email(@friendship)
        @email.from_addrs.first.name.should == "#{@friendship.user.full_name} via UEnd"
        @email.from_addrs.first.address.should == "info@uend.org"
      end
    end
  end

  describe "project poi" do
    before do
      @project = Factory(:project)
      @project_poi = Factory(:project_poi, :project => @project)
    end

    it "should be sent out" do
      @email = DonortrustMailer.create_project_poi(@project_poi, "msg")
      @email.to_addrs.first.name.should == @project_poi.name
      @email.to_addrs.first.address.should == @project_poi.email
      @email.body.should =~ /#{@project_poi.token}/
    end

    it "should throw an error if the project_poi is unsubscribed" do
      @project_poi.update_attributes(:unsubscribed => true)
      lambda {
        @email = DonortrustMailer.create_project_poi(@project_poi, "msg")
      }.should raise_error(RuntimeError)
    end
  end
end
