require File.dirname(__FILE__) + '/../../test_helper'
require File.dirname(__FILE__) + '/../../bdrb_test_helper'
require 'workers/account_reminder_worker'

context "AccountReminderWorker Tests" do
  setup do
    @users = []
    (6..9).each do |i|
      user = User.new
      user.stubs(:last_logged_in_at).returns(i.months.ago)
      @users << user
    end
    User.stubs(:find_old_accounts).returns(@users)

    @worker = AccountReminderWorker.new
    @worker.stubs(:find_old_accounts).returns(@users)
  end
  
  specify "should call find_old_accounts" do
    @users.each{|u| u.stubs(:send_account_reminder).returns(true)}
    @worker.expects(:find_old_accounts).returns(@users)
    @worker.do_work
  end
  
  specify "should call send_account_reminder on each user" do
    @users.each{|u| u.expects(:send_account_reminder).returns(true)}
    @worker.do_work
  end
  
  specify "DonortrustMailer should expect deliver_account_expiry_reminder on each user" do
    @users.each{|u| DonortrustMailer.expects(:deliver_account_expiry_reminder).with(u).returns(true)}
    @worker.do_work
  end
end
