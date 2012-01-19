namespace :scheduler do
  desc "Remind users of stale accounts"
  task :account_reminder => :environment do
    puts "[#{Time.now.utc.to_s}] Checking for Old Accounts to send reminders for"
    @warning_dates = [6.months.ago.to_date, 9.months.ago.to_date, 11.months.ago.to_date, (11.months+3.weeks).ago.to_date]
    @users = []
    User.find_old_accounts.each do |user|
      @users << user if @warning_dates.include?(user.last_logged_in_at.to_date)
    end
    users.each {|user| user.send_account_reminder }
    num_sent = @users.size
    # puts @users.map(&:last_logged_in_at)
    puts "[#{Time.now.utc.to_s}] Old Account Reminder Emails Sent: #{@users.size} [#{@users.map(&:id).join(', ')}]"
  end

  desc "Process stale accounts"
  task :process_stale_accounts => :environment do
    puts "[#{Time.now.utc.to_s}] Checking for Old Accounts to process"
    @expired_users = []
    @expired_users = User.expired.all.select{|user| user.balance > 0 }
    @expired_users.each {|user| user.expire_account_balance }
    puts "[#{Time.now.utc.to_s}] Expired Account Emails Sent: #{@expired_users.size} [#{@expired_users.map(&:id).join(', ')}]"
  end

  desc "Send scheduled gifts"
  task :gift_mailer => :environment do
    puts "[#{Time.now.utc.to_s}] Checking for scheduled Gifts to Email"
    gifts = Gift.sendable
    gifts.each {|gift| gift.send_gift_mail}
    num_sent = gifts.size
    puts "[#{Time.now.utc.to_s}] Scheduled Gift Emails Sent: #{num_sent} [#{gifts.map(&:id).join(', ')}]"
  end
  
  desc "Send unopened gift reminders"
  task :gift_reminder => :environment do
    puts "[#{Time.now.utc.to_s}] Checking for Gifts to send reminders for"
    gifts = Gift.find_unopened_gifts.inject([]) do |gifts, gift|
      gifts << gift if [7, 2, 1].include?(gift.expiry_in_days)
    end
    gifts ||= []
    gifts.each {|gift| gift.send_gift_reminder }
    num_sent = gifts.size
    puts "[#{Time.now.utc.to_s}] Reminder Gift Emails Sent: #{num_sent} [#{gifts.map(&:id).join(', ')}]"
  end

  desc "Clean out stale sessions"
  task :session_cleaner => :environment do
    deleted_count = ActiveRecord::SessionStore::Session.delete_all( ['updated_at <?', 20.minutes.ago] ) 
    puts "[#{Time.now.utc.to_s}] Deleted inactive sessions (#{deleted_count})"
  end
end
