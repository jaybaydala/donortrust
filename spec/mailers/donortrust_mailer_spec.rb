require File.dirname(__FILE__) + '/../spec_helper'

describe DonortrustMailer do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include ActionController::UrlWriter

  before  do  
    @user = Factory(:user, {:activation_code => "1234", :last_logged_in_at => 7.months.ago})
    ActionMailer::Base.deliveries = []  
  end

  subject { @user }

  context 'New signup notification to admin' do
    before do 
      @subscription = Factory(:subscription)
      @mail = DonortrustMailer.create_new_subscription_notification(@subscription)
    end

    it 'should send a notification to admin' do
      @mail.should deliver_to("jay.baydala@uend.org")
    end

    it 'should send have user name in body' do
      @mail.should have_body_text(/#{@subscription.first_name} #{@subscription.last_name}/)
    end

    it 'should send have user email in body' do
      @mail.should have_body_text(/#{@subscription.email}/)
    end

    it 'should send have user email in body' do
      @mail.should have_body_text(/#{@subscription.email}/)
    end
  end

  context "User change notification" do
    before { @mail = DonortrustMailer.create_user_change_notification(@user) }
   
    it "should deliver to user's email" do
      @mail.should deliver_to(@user.email)
    end

    it "should deliver from info@uend.org" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'Welcome to DonorTrust! UEnd: Account Email Confirmation'" do
      @mail.should have_subject('Welcome to DonorTrust! UEnd: Account Email Confirmation')
    end

    it "should activation url in the body" do
      url = activate_dt_accounts_url(:id => @user.activation_code, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape url}/)
    end
  end

  context "User password reset" do
    before { @mail = DonortrustMailer.create_user_password_reset(@user) }
   
    it "should deliver to user's email" do
      @mail.should deliver_to(@user.email)
    end

    it "should deliver from info@uend.org" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'Your UEnd: password has been reset'" do
      @mail.should have_subject('Your UEnd: password has been reset')
    end

    it "should activation url in the body" do
      url = login_url(:host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape url}/)
    end

  end

  context "Account expiry reminder" do
    before { @mail = DonortrustMailer.create_account_expiry_reminder(@user) }
   
    it "should deliver to user's email" do
      @mail.should deliver_to(@user.email)
    end

    it "should deliver from info@uend.org" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'Your UEnd: account'" do
      @mail.should have_subject('Your UEnd: account')
    end

    it "should have balance in the body" do
      @mail.should have_body_text(/You currently have a balance of #{Regexp.escape(number_to_currency @user.balance)}/)
    end

  end

  context "Account expiry processed" do
    before { @mail = DonortrustMailer.create_account_expiry_processed(@user) }
   
    it "should deliver to info@uend.org and tim@tag.ca" do
      @mail.should deliver_to(["info@uend.org", "tim@tag.ca"])
    end

    it "should deliver from info@uend.org" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'Expired UEnd: account'" do
      @mail.should have_subject('Expired UEnd: account')
    end

    it "should have user name, login and balance the body" do
      @mail.should have_body_text(/#{@user.name} \(#{@user.login}\) had a balance of #{Regexp.escape(number_to_currency @user.balance)}/)
    end

  end

  context "Gift request" do
    before do
      @requestee_profile = Factory(:profile)
      @mail = DonortrustMailer.create_gift_request(@requestee_profile, @user)
    end

    it "should deliver to requestee's email" do
      @mail.should deliver_to(@requestee_profile.user.email)
    end

    it "should have subject 'What I Really Want...'" do
      @mail.should have_subject("What I Really Want...")
    end

  end

  context "New place notification" do
    before do
      @place = Factory(:place)
      @place.stub(:country).and_return(Factory(:country))
      @mail = DonortrustMailer.create_new_place_notify(@place)
    end

    it "should deliver to 'info@uend.org'" do
      @mail.should deliver_to("info@uend.org")
    end

    it "should deliver from 'info@uend.org'" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'A new place has been created'" do
      @mail.should have_subject("A new place has been created")
    end

    it "should have place name in body" do
      @mail.should have_body_text(/#{@place.name}/)
    end

    it "should have place's country name in the body" do
      @mail.should have_body_text(/#{@place.country.name}/)
    end
  
  end

  context "Gift resend sender" do

    before do
      @gift = Factory(:gift)
      @mail = DonortrustMailer.create_gift_resend_sender(@gift)
    end

    it "should deliver to gift's email address" do
      @mail.should deliver_to(@gift.email)
    end

    it "should deliver from 'info@uend.org'" do
      @mail.should deliver_from("info@uend.org")
    end

    it "should have subject 'Resent: You have been gifted'" do
      @mail.should have_subject("Resent: You have been gifted!")
    end

  end

  context "UPowered email subscription" do
    
    before do
      @email_subscription = Factory(:upowered_email_subscribe)
      @mail = DonortrustMailer.create_upowered_email_subscription(@email_subscription)
    end

    it "should deliver to subscribed email" do
      @mail.should deliver_to(@email_subscription.email)
    end

    it "should deliver from 'upowered@uend.org'" do
      @mail.should deliver_from('upowered@uend.org')
    end

    it "should subject 'U:Powered campaign updates'" do
      @mail.should have_subject("U:Powered campaign updates")
    end

    it "should have unsubscribe url" do
      unsubscribe_url = unsubscribe_dt_upowered_email_subscribe_url(@email_subscription.code, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape unsubscribe_url}/)
    end

  end

  context "Subscription thanks" do
    before do
      @subscription = Factory(:subscription)
      @mail = DonortrustMailer.create_subscription_thanks(@subscription)
    end

    it "should deliver to subscription email" do
      @mail.should deliver_to(@subscription.email)
    end

    it "should deliver from 'upowered@uend.org'" do
      @mail.should deliver_from('upowered@uend.org')
    end

    it "should subject 'UPowered: Thank you!'" do
      @mail.should have_subject("UPowered: Thank you!")
    end

  end

  context "Subscription failure" do

    before do
      @subscription = Factory(:subscription)
      @mail = DonortrustMailer.create_subscription_failure(@subscription)
    end

    it "should deliver to subscription email" do
      @mail.should deliver_to(@subscription.email)
    end

    it "should deliver from 'upowered@uend.org'" do
      @mail.should deliver_from('upowered@uend.org')
    end

    it "should subject 'UPowered: Subscription Problem'" do
      @mail.should have_subject("UPowered: Subscription Problem")
    end

    it "should have edit subscription url in body" do
      edit_iend_subscription_url = edit_iend_subscription_url(:id => @subscription.id, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape edit_iend_subscription_url}/)
    end

  end

  context "Impending subscription card expiration notice" do
    before do
      @subscription = Factory(:subscription)
      @mail = DonortrustMailer.create_impending_subscription_card_expiration_notice(@subscription)
    end

    it "should deliver to subscription email" do
      @mail.should deliver_to(@subscription.email)
    end

    it "should deliver from 'upowered@uend.org'" do
      @mail.should deliver_from('upowered@uend.org')
    end

    it "should subject 'UPowered: Impending card expiry'" do
      @mail.should have_subject("UPowered: Impending credit card expiry")
    end

    it "should have edit subscription url in body" do
      edit_iend_subscription_url = edit_iend_subscription_url(:id => @subscription.id, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape edit_iend_subscription_url}/)
    end

  end

  context "Tax receipt" do
    before do
      @tax_receipt = Factory(:tax_receipt)
      @mail = DonortrustMailer.create_tax_receipt(@tax_receipt)
    end

    it "should deliver to tax receipts email" do
      @mail.should deliver_to(@tax_receipt.email)
    end

    it "should deliver from 'info@uend.org'" do
      @mail.should deliver_from('info@uend.org')
    end

    it "should subject 'UEnd: Tax Receipt'" do
      @mail.should have_subject("UEnd: Tax Receipt")
    end

  end

  context "Friendship request email" do
    before do
      @friendship = Factory(:friendship)
      @mail = DonortrustMailer.create_friendship_request_email(@friendship)
    end

    it "should deliver to friend's email" do
      @mail.should deliver_to(@friendship.friend.email)
    end

    it "should have subject 'Friendship request'" do
      @mail.should have_subject("Friendship request")
    end

    it "should have accept url in body" do
      accept_url = accept_iend_friendship_url(@friendship, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape accept_url}/)
    end

    it "should have decline url in body" do
      decline_url = decline_iend_friendship_url(@friendship, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape decline_url}/)
    end

    it "should have initiator's email in body" do
      @mail.should have_body_text(/#{@friendship.user.email}/)
    end
  end

  context "Friendship acceptance email" do
    before do
      @friendship = Factory(:friendship)
      @mail = DonortrustMailer.create_friendship_acceptance_email(@friendship)
    end

    it "should deliver to initiator's email" do
      @mail.should deliver_to(@friendship.user.email)
    end

    it "should have subject 'Friendship request accepted'" do
      @mail.should have_subject("Friendship request accepted")
    end

    it "should have friend's email in body" do
      @mail.should have_body_text(/#{@friendship.friend.email}/)
    end
  end

  context "Project fully funded" do
    before do
      @project = Factory(:project)
      @mail = DonortrustMailer.create_project_fully_funded(@project)
    end

    it "should be delivered to 'info@uend.org'" do
      @mail.should deliver_to('info@uend.org')
    end

    it "should be delivered from 'info@uend.org'" do
      @mail.should deliver_from('info@uend.org')
    end

    it "should have subject 'UEnd Project Fully Funded'" do
      @mail.should have_subject("UEnd Project Fully Funded")
    end

    it "should have project name in body" do
      @mail.should have_body_text(/#{@project.name}/)
    end

    it "should have project url in body" do
      project_url = dt_project_url(@project, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape project_url}/)
    end

    it "should have admin url in body" do
      admin_url = bus_admin_project_url(@project, :host => "localhost:3000")
      @mail.should have_body_text(/#{Regexp.escape admin_url}/)
    end
  end
end
