require File.dirname(__FILE__) + '/../spec_helper'

describe Gift do
  before do
    @gift = Factory(:gift)
  end
  
  it "should create a gift" do
    lambda{ Factory(:gift) }.should change(Gift, :count).by(1)
  end
  
  describe "validations" do
    it "should belong_to user" do
      @gift.should belong_to(:user)
    end
    it "should belong_to project" do
      @gift.should belong_to(:project)
    end
    it "should belong_to e_card" do
      @gift.should belong_to(:e_card)
    end
    it "should belong_to order" do
      @gift.should belong_to(:order)
    end
    it "should have_one deposit" do
      @gift.should have_one(:deposit)
    end
    it "should validate_presence_of amount" do
      @gift.should validate_presence_of(:amount)
    end
    it "should validate_presence_of email" do
      @gift.should validate_presence_of(:email)
    end
    it "should validate_presence_of to_email" do
      @gift.should validate_presence_of(:to_email)
    end
    # it "should validate_numericality_of amount" do
    #   @gift.should validate_numericality_of(:amount)
    # end
  end
  describe "amount" do
    it "should be numerical" do
      @gift.amount = "hi"
      @gift.valid?
      @gift.errors.on(:amount).should_not be_nil
    end
    it "should be positive" do
      @gift.amount = -1
      @gift.valid?
      @gift.errors.on(:amount).should_not be_nil
    end
    it "should strip a '$' from an amount" do
      @gift.amount = "$100.25"
      @gift.amount.to_s.should == "100.25"
    end
  end
  
  describe "balance" do
    it "should be the same as the amount" do
      @gift.balance.should == @gift.amount
    end
    it "should be nil if a project is selected" do
      @gift.project = Factory(:project)
      @gift.save
      @gift.balance.should be_nil
    end
    it "should not get changed when getting updated" do
      @gift.balance = 20
      @gift.save
      @gift.balance.should == 20
    end
  end

  describe "send_at" do
    it "should allow future dates on creation" do
      @gift = Factory(:gift, :send_at => 1.day.from_now)
      @gift.errors.on(:send_at).should be_nil
    end
    it "should not allow past dates on creation" do
      @gift = Factory.build(:gift, :send_at => Time.now - 1)
      @gift.valid?
      @gift.errors.on(:send_at).should_not be_nil
    end
    it "should allow future or past dates on update" do
      @gift = Factory(:gift)
      @gift.update_attributes(:send_at => Time.now - 1).should be_true
      @gift.update_attributes(:send_at => Time.now + 10).should be_true
    end
  end

  describe "send_email" do
    it "should be set to true if 'now'" do
      @gift.send_email = "now"
      @gift.send_email.should be_true
    end
    it "should set send_at to Time.now + 20.minutes " do
      now = Time.now
      Time.stub!(:now).and_return(now)
      @gift.send_email = "now"
      @gift.send_at = 2.days.from_now
      @gift.send_at.should == now + 20.minutes
    end
  end
  
  describe "find_unopened_gifts" do
    it "should only find gifts with a pickup_code and that hasn't been sent" do
      @picked_up = Factory(:gift)
      @picked_up.pickup
      @sent = Factory(:gift)
      @sent.send_gift_mail
      # Gift.find_unopened_gifts.should == [@gift]
      Gift.find_unopened_gifts.each do |gift|
        gift.pickup_code.should_not be_nil
        gift.sent_at.should_not be_nil
      end
    end
  end

  it "should create a pickup_code" do
    @gift.pickup_code.should_not be_nil
  end
  describe "pickup" do
    it "should set pickup_code to nil" do
      @gift.pickup
      @gift.pickup_code.should be_nil
    end
    it "should be picked_up?" do
      @gift.pickup
      @gift.picked_up?.should be_true
    end
    it "should set picked_up_at to Time.now" do
      time = Time.now
      Time.stub!(:now).and_return(time)
      @gift.pickup
      @gift.picked_up_at.should == time
    end
  end
  
  describe "with a project" do
    before do
      @project = Factory(:project)
      @project.update_attributes(:total_cost => 100)
      @project.stub!(:dollars_raised).and_return(90)
    end
    it "should not allow an amount to be greater than the projects current_need" do
      @gift.project = @project
      @gift.update_attributes(:amount => 10.01)
      @gift.errors.on(:amount).should_not be_nil
    end
    it "should allow an amount to be equal than the projects current_need" do
      @gift.project = @project
      @gift.update_attributes(:amount => 10.00)
      @gift.errors.on(:amount).should be_nil
    end
  end
  
  describe "gift notifications" do
    before do
      ActionMailer::Base.delivery_method = :test
      ActionMailer::Base.perform_deliveries = true
      ActionMailer::Base.deliveries = []
      time = Time.now
      Time.stub!(:now).and_return(time)
      @gift.update_attributes(:send_at => time)
    end
    
    describe "pickup" do
      it "should not notify the giver if notify_giver? is false" do
        @gift.notify_giver = false
        lambda {
          @gift.pickup
        }.should_not change(ActionMailer::Base.deliveries, :size)
      end
      it "should notify the giver if notify_giver? is true" do
        @gift.notify_giver = true
        lambda {
          @gift.pickup
        }.should change(ActionMailer::Base.deliveries, :size)
      end
      it "should send the right email" do
        @gift.notify_giver = true
        @gift.pickup
        mail = ActionMailer::Base.deliveries[0]
        mail.to.include?(@gift.email).should be_true
        mail.subject.should == "Your UEnd: gift has been opened"
      end
    end
  end
end

#context "Gift Notification" do
#  specify "send_gift_mail? should be false if send_at is not nil" do
#  specify "send_gift_mail? should be true if send_at is nil" do
#  specify "send_gift_mail should set sent_at to not be nil" do
#  specify "send_gift_mail should create an email" do
#end