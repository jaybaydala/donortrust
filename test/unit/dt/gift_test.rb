require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/gift_test_helper'

# see user_transaction_test.rb for amount and user tests
context "Gift" do
  include GiftTestHelper
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :gifts, :users, :projects

  setup do
  end

  specify "Gift table should be 'gifts'" do
    Gift.table_name.should.equal 'gifts'
  end

  specify "should create a gift" do
    Gift.should.differ(:count).by(1) { create_gift } 
  end

  specify "if there's no user_id, the credit_card parameters are required" do
    lambda {
      t = create_gift(:user_id => nil)
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Gift, :count)
    lambda {
      t = create_gift(credit_card_params(:user_id => nil))
      t.errors.on(:credit_card).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "should require amount" do
    lambda {
      t = create_gift(:amount => nil)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require a message" do
    lambda {
      t = create_gift(credit_card_params(:message => nil))
      t.errors.on(:message).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "amount should be numerical" do
    lambda {
      t = create_gift(:amount => "hello")
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "amount should be positive" do
    lambda {
      t = create_gift(:amount => 0)
      t.errors.on(:amount).should.not.be.nil
      t = create_gift(:amount => -1)
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require to_name" do
    lambda {
      t = create_gift(credit_card_params(:to_name => nil))
      t.errors.on(:to_name).should.be.nil
    }.should.change(Gift, :count)
  end
  
  specify "should require to_email" do
    lambda {
      t = create_gift(:to_email => nil)
      t.errors.on(:to_email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "to_email_confirmation should match to_email" do
    lambda {
      t = create_gift(:to_email_confirmation => "")
      t.errors.on(:to_email).should.not.be.nil
      t = create_gift(:to_email_confirmation => "nomatch@example.com")
      t.errors.on(:to_email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "email_confirmation should match email" do
    lambda {
      t = create_gift(:email_confirmation => "")
      t.errors.on(:email).should.not.be.nil
      t = create_gift(:email_confirmation => "nomatch@example.com")
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require name" do
    lambda {
      t = create_gift(credit_card_params(:name => nil))
      t.errors.on(:name).should.be.nil
    }.should.change(Gift, :count)
  end
  
  specify "should require email" do
    lambda {
      t = create_gift(:email => nil)
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "should not require project_id" do
    lambda {
      t = create_gift(credit_card_params(:project_id => nil))
      t.errors.on(:project_id).should.be.nil
    }.should.change(Gift, :count)
  end
  
  specify "should not require send_at" do
    lambda {
      t = create_gift(credit_card_params(:send_at => nil))
      t.errors.on(:send_at).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "send_at should allow future dates" do
    lambda {
      t = create_gift(credit_card_params(:send_at => Time.now + 2))
      t.errors.on(:send_at).should.be.nil
    }.should.change(Gift, :count)
  end

  specify "send_at should not allow current or past dates" do
    lambda {
      t = create_gift(credit_card_params(:send_at => Time.now))
      t.errors.on(:send_at).should.not.be.nil
    }.should.not.change(Gift, :count)
  end

  specify "send_at should allow current or past dates on update" do
    t = create_gift(credit_card_params(:send_at => 1.second.from_now))
    t.update_attributes(:send_at => 1.second.ago).should.equal true
  end
  
  specify "creating a Gift should create a UserTransaction if user_id is present" do
    lambda {
      t = create_gift()
    }.should.not.change(UserTransaction, :count)
    
    lambda {
      t = create_gift(credit_card_params(:user_id => 1))
    }.should.change(UserTransaction, :count)
  end

  specify "sum should return a negative amount if !credit_card" do
    t = create_gift(:user_id => 1)
    t.sum.should.be < 0
  end

  specify "sum should return 0 if credit_card" do
    t = create_gift(credit_card_params)
    t.sum.should.be 0
  end

  specify "should error on invalid credit_card" do
    lambda {
      t = create_gift(credit_card_params(:credit_card => 4111111111111112) )
      t.errors.on(:credit_card).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should require card_expiry first_name last_name address city postal_code country if credit_card != nil" do
    %w( card_expiry first_name last_name address city postal_code country ).each {|f|
      lambda {
        fsym = f.to_sym
        t = create_gift(credit_card_params(fsym => nil))
        t.errors.on(fsym).should.not.be.nil
      }.should.not.change(Deposit, :count)
    }
  end

  specify "card_expiry= should take a variety of formats and come out as the last day the month specified" do
    date = Date.civil(2009, 4, -1).to_s
    d = Deposit.new
    [ "04/09", "04/2009", "0409", "04 09", ["04", "09"], "2009-04-30", "2009-04-20", Date.civil(2009, 4, 20) ].each do |exp|
      d.card_expiry = exp
      d.card_expiry.to_s.should.equal date 
    end
  end

  specify "card_expiry= should be current or future" do
    d = Deposit.new
    today = Date.today
    [ today, Date.civil(today.year, today.month, -1), today+1, today+31, today+365 ].each do |exp|
      t = create_gift(credit_card_params(:credit_card => 4111111111111111, :card_expiry => exp))
      t.errors.on(:card_expiry).should.be.nil
    end
    [ today-365, today-31 ].each do |exp|
      t = create_gift(credit_card_params(:credit_card => 4111111111111111, :card_expiry => exp))
      t.errors.on(:card_expiry).should.not.be.nil
    end
  end

  specify "should error on invalid card_expiry" do
    lambda {
      t = create_gift(credit_card_params(:credit_card => 4111111111111111, :card_expiry => 4009 ))
      t.errors.on(:card_expiry).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "amount should strip a prepended $" do
    lambda {
      t = create_gift( credit_card_params.merge(:amount => '$100.00') )
      t.errors.on(:amount).should.be.nil
      t.amount.should.equal 100.00
    }.should.change(Gift, :count)
  end

  specify "after save, credit_card should only contain the last 4 digits of the card number" do
    card_number = 4111111111111111
    t = create_gift(credit_card_params(:credit_card => card_number ))
    t.credit_card.should.equal card_number.to_s[-4, 4]
  end

  specify "if user_id != nil and credit_card == nil, cannot give more than the user's current balance" do
    balance = User.find(users(:quentin).id).balance
    lambda {
      t = create_gift( :user_id => users(:quentin).id, :amount => balance + 0.01 )
      t.errors.on(:amount).should.not.be.nil
    }.should.not.change(Deposit, :count)
  end

  specify "should create a pickup_code" do
    t = create_gift
    t.pickup_code.should.not.be nil
  end

  specify "pickup should make pickup_code == nil" do
    t = create_gift
    t.pickup
    t.pickup_code.should.be nil
  end

  specify "picked_up? should return true after pickup" do
    t = create_gift
    t.picked_up?.should.be false
    t.pickup
    t.picked_up?.should.be true
  end

  specify "pickup should make picked_up_at == Time.now()" do
    t = create_gift
    t.pickup
    t.picked_up_at.to_formatted_s.should.equal Time.now.utc.to_formatted_s
  end

  specify "amount cannot be greater than the project.current_need" do
    @project = Project.find_public(:first)
    lambda {
      g = create_gift(:project_id => @project.id, :amount => @project.current_need + 1)
      g.errors.on(:amount).should.not.be.nil
    }.should.not.change(Gift, :count)
  end
end

context "Gift Notification" do
  include GiftTestHelper
  include DtAuthenticatedTestHelper
  fixtures :user_transactions, :gifts, :users
  
  setup do
    # for testing action mailer
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    @emails = ActionMailer::Base.deliveries 
    @emails.clear
  end
  
  specify "send_gift_mail? should be false if send_at is not nil" do
    t = create_gift(credit_card_params(:send_at => Time.now + 2))
    t.send_gift_mail?.should.be false
  end
  
  specify "send_gift_mail? should be true if send_at is nil" do
    t = create_gift(credit_card_params(:send_at => nil))
    t.send_gift_mail?.should.be true
  end
  
  specify "send_gift_mail should set sent_at to not be nil" do
    t = create_gift(credit_card_params(:send_at => nil))
    t.sent_at.should.be.nil
    t.send_gift_mail
    t.sent_at.should.not.be.nil
  end
  
  specify "send_gift_mail should create an email" do
    t = create_gift(credit_card_params(:send_at => nil))
    t.send_gift_mail
    @emails.length.should.equal 1
    @emails.first.subject.should =~ /^You have been gifted!/
    @emails.first.body.should    =~ /chose to give you a new kind of gift through the ChristmasFuture website/
    @emails.first.body.should    =~ /Pickup Code: #{t.pickup_code}/
  end
end