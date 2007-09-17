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
  
  specify "should set @subject to 'Welcome to DonorTrust! ChristmasFuture Account Activation'" do
    @user_notifier.subject.should == "Welcome to DonorTrust! ChristmasFuture Account Activation"
  end
  
  specify "should set @from to info@christmasfuture.org" do
    @user_notifier.from.should == ( ["info@christmasfuture.org"])
  end
  
  specify "should contain login reminder (User: quire@example.com) in mail body" do
    @user_notifier.body.should =~ ( /Username: quire@example.com/ )
  end
  
  specify "should contain password reminder (Password: quire) in mail body" do
    @user_notifier.body.should =~ ( /Password: quire/ )
  end
  
  specify "should contain user activation url /dt/accounts;activate?id=[A-Za-z0-9]+) in mail body" do
    @user_notifier.body.should =~ ( %r{/dt/accounts;activate\?id=[A-Za-z0-9]+} )
  end

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirename', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
  end

  private
  def read_fixture(action)
    IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
  end

  def encode(subject)
    quoted_printable(subject, CHARSET)
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
    @gift = create_gift(credit_card_params)
  end


  specify "gift_mail should match fixture" do
    @expected.subject = 'You have received a ChristmasFuture Gift from ' + ( @gift.name != nil ? @gift.name : @gift.email )
    @expected.body    = read_fixture('gift_mail')
    @expected.date    = Time.now

    email = DonortrustMailer.create_gift_mail(@gift).encoded
    email.should =~ @gift.to_name
    email.should =~ @gift.to_email
    email.should =~ @gift.name
    email.should =~ @gift.email
  end

  xspecify "gift_open should match fixture" do
    @expected.subject = 'GiftNotifier#open'
    @expected.body    = read_fixture('gift_open')
    @expected.date    = Time.now

    assert_equal @expected.encoded, DonortrustMailer.create_gift_open(@gift).encoded
  end

  xspecify "gift_remind should match fixture" do
    @expected.subject = 'GiftNotifier#remind'
    @expected.body    = read_fixture('gift_remind')
    @expected.date    = Time.now

    assert_equal @expected.encoded, DonortrustMailer.create_gift_remind(@gift).encoded
  end

  private
    def read_fixture(action)
      IO.readlines("#{FIXTURES_PATH}/donortrust_mailer/#{action}")
    end

    def encode(subject)
      quoted_printable(subject, CHARSET)
    end
end