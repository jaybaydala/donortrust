require File.dirname(__FILE__) + '/../../test_helper'
require 'donortrust_mailer'

context "DonortrustMailer on user_signup_notification" do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures'
  CHARSET = "utf-8"
  
  include ActionMailer::Quoting
  fixtures :users
  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }

    @user = create_user
    @user_notifier = DonortrustMailer.create_user_signup_notification(@user)
  end
  
  specify "should set @recipients to user's email" do
    @user_notifier.to.should == ["quire@example.com"]
  end
  
  specify "should set @subject to 'The future is here.'" do
    @user_notifier.subject.should == "The future is here."
  end
  
  specify "should set @from to info@uend.org" do
    @user_notifier.from.should == ( ["info@uend.org"])
  end
  
  specify "should contain login reminder (User: quire@example.com) in mail body" do
    @user_notifier.body.should =~ ( /Username: quire@example.com/ )
  end
  
  specify "should contain password reminder (Password: quire) in mail body" do
    @user_notifier.body.should =~ ( /Password: quire/ )
  end
  
  specify "should contain user activation url /dt/accounts;activate?id=[A-Za-z0-9]+) in mail body" do
    @user_notifier.body.should =~ ( %r{/dt/accounts;activate\?id=[a-z0-9]+}i )
  end

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirename', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => 'Canada' }.merge(options))
  end

  private
  def read_fixture(action)
    IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
  end

  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end

context "DonortrustMailer on user_password_reset" do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures' if FIXTURES_PATH.nil?
  CHARSET = "utf-8" if CHARSET.nil?
  
  include ActionMailer::Quoting
  fixtures :users
  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    
    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }

    @user = create_user
  end

  specify "user_password_reset shouldn't throw any errors" do
    DonortrustMailer.create_user_password_reset(@user)
  end

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirename', :password => 'quire', :password_confirmation => 'quire', :terms_of_use => '1', :country => "Canada" }.merge(options))
  end
end


#context "A UserNotifier on activation" do
#  setup do
#    set_mailer_in_test
#    
#    @user = mock("user")
#    @user.stub!(:email).and_return('user@test.com')
#    @user.stub!(:login).and_return('user')
#    
#    @user_notifier = UserNotifier.create_activation(@user)
#  end
#  
#  xspecify "should set @recipients to user's email" do
#    @user_notifier.to.should eql( ["user@test.com"])
#  end
#  
#  xspecify "should set @subject to [YOURSITE] Your account has been activated!" do
#    @user_notifier.subject.should eql( "[YOURSITE] Your account has been activated!")
#  end
#  
#  xspecify "should set @from to ADMINEMAIL" do
#    @user_notifier.from.should eql( ["ADMINEMAIL"])
#  end
#  
#  xspecify "should contain login reminder (user,) in mail body" do
#    @user_notifier.body.should match( %r{user,})
#  end
#  
#  xspecify "should contain website url (http://YOURSITE/) in mail body" do
#    @user_notifier.body.should match( %r{http://YOURSITE/})
#  end
#end

require File.dirname(__FILE__) + '/gift_test_helper'
context "DonortrustMailer gift_mail Test" do
  include GiftTestHelper
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures' if FIXTURES_PATH == nil
  CHARSET = "utf-8" if CHARSET == nil

  include ActionMailer::Quoting

  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end


  specify "gift_mail should match the @gift" do
    @gift = create_gift(credit_card_params)
    @expected.subject = 'You have received a Uend: Gift from ' + ( @gift.name != nil ? @gift.name : @gift.email )
    @expected.date    = Time.now

    email = DonortrustMailer.create_gift_mail(@gift).encoded
    email.should =~ @gift.to_name
    email.should =~ @gift.to_email
    email.should =~ @gift.name
    email.should =~ @gift.email
  end

  specify "gift_expiry_reminder should contain an expiry note" do
    @gift = create_gift(credit_card_params)
    @gift.update_attribute('sent_at', 23.days.ago)
    @gift.stubs(:expiry_date).returns(Time.now + 7.days + 1.minute)
    email = DonortrustMailer.create_gift_expiry_reminder(@gift).encoded
    email.should =~ @gift.to_name
    email.should =~ @gift.to_email
    email.should =~ @gift.name
    email.should =~ @gift.email
    email.should =~ "Your gift will expire in #{@gift.expiry_in_days} day(s)!"
  end

  specify "gift_expiry_notifier should contain an expiry note" do
    @gift = create_gift(credit_card_params)
    @gift.update_attribute('sent_at', 23.days.ago)
    @gift.stubs(:expiry_date).returns(Time.now + 7.days + 1.minute)
    email = DonortrustMailer.create_gift_expiry_notifier(@gift).encoded
    email.should =~ @gift.to_name
    email.should =~ @gift.to_email
    email.should =~ @gift.name
    email.should =~ @gift.email
    email.should =~ "Your gift will expire in #{@gift.expiry_in_days} day(s)!"
  end

  private
  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end

context "DonortrustMailer account_expiry_mailer Tests" do
  FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures' if FIXTURES_PATH == nil
  CHARSET = "utf-8" if CHARSET == nil

  include ActionMailer::Quoting

  setup do
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
    
    @user = User.new
    @user.stubs(:id).returns(1)
    @user.stubs(:name).returns("Mocked User")
    @user.stubs(:balance).returns(25)
    @user.stubs(:last_logged_in_at).returns(7.months.ago)
    User.stubs(:find).returns(@user)
  end

  specify "send_account_reminder should have the necessary content" do
    @user.send_account_reminder
    
    @expected.subject = 'Your Uend: Account'
    @expected.date    = Time.now
  
    email = DonortrustMailer.create_account_expiry_reminder(@user).encoded
    email.should =~ @user.full_name
    email.should =~ "You have not logged into your Uend: account since #{@user.last_logged_in_at.to_formatted_s(:long)}"
    email.should =~ "balance of #{number_to_currency(@user.balance)}"
  end

  private
  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end