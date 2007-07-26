require File.dirname(__FILE__) + '/../../test_helper'
require 'user_notifier'

#context "UserNotifier" do
#  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
#  CHARSET = "utf-8"
#
#  include ActionMailer::Quoting
#  fixtures :users
#  
#  setup do
#    ActionMailer::Base.delivery_method = :test
#    ActionMailer::Base.perform_deliveries = true
#    ActionMailer::Base.deliveries = []
#
#    @expected = TMail::Mail.new
#    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
#  end
#  
#  xspecify 'truth' do
#    true.should.be true
#  end
#
#  private
#    def read_fixture(action)
#      IO.readlines("#{FIXTURES_PATH}/user_notifier/#{action}")
#    end
#
#    def encode(subject)
#      quoted_printable(subject, CHARSET)
#    end
#end


context "A UserNotifier on signup_notification" do
  fixtures :users
  setup do
    @user = create_user
    @user_notifier = UserNotifier.create_signup_notification(@user)
  end
  
  specify "should set @recipients to user's email" do
    @user_notifier.to.should == ["quire@example.com"]
  end
  
  specify "should set @subject to Welcome to DonorTrust! Please activate your new account" do
    @user_notifier.subject.should == "Welcome to DonorTrust! Please activate your new account"
  end
  
  specify "should set @from to info@christmasfuture.org" do
    @user_notifier.from.should == ( ["info@christmasfuture.org"])
  end
  
  specify "should contain login reminder (User: aaron@example.com) in mail body" do
    @user_notifier.body.should =~ ( /Username: quire@example.com/ )
  end
  
  specify "should contain password reminder (Password: quire) in mail body" do
    @user_notifier.body.should =~ ( /Password: quire/ )
  end
  
  specify "should contain user activation url (http://www.christmasfuture.org/dt/accounts;activate?id=[A-Za-z0-9]+) in mail body" do
    @user_notifier.body.should =~ ( %r{http://www.christmasfuture.org/dt/accounts;activate\?id=[A-Za-z0-9]+} )
  end

  private
  def create_user(options = {})
    User.create({ :login => 'quire@example.com', :first_name => 'Quire', :last_name => 'Tester', :display_name => 'Quirename', :password => 'quire', :password_confirmation => 'quire' }.merge(options))
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
#  specify "should set @recipients to user's email" do
#    @user_notifier.to.should eql( ["user@test.com"])
#  end
#  
#  specify "should set @subject to [YOURSITE] Your account has been activated!" do
#    @user_notifier.subject.should eql( "[YOURSITE] Your account has been activated!")
#  end
#  
#  specify "should set @from to ADMINEMAIL" do
#    @user_notifier.from.should eql( ["ADMINEMAIL"])
#  end
#  
#  specify "should contain login reminder (user,) in mail body" do
#    @user_notifier.body.should match( %r{user,})
#  end
#  
#  specify "should contain website url (http://YOURSITE/) in mail body" do
#    @user_notifier.body.should match( %r{http://YOURSITE/})
#  end
#end
