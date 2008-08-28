class AccountReminderWorker < BackgrounDRb::MetaWorker
  set_worker_name :account_reminder_worker
  reload_on_schedule true
  
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def do_work(args = nil)
    logger.info "[#{Time.now.utc.to_s}] Checking for Old Accounts to send reminders for"
    users = find_old_accounts
    users.each do |u|
      u.send_account_reminder
    end
    logger.info "[#{Time.now.utc.to_s}] Old Account Reminder Emails Sent: #{users.size} [#{users.map{|u|u.id}.join(', ')}]"
  end

  def find_old_accounts
    users = []
    warning_dates = [6.months.ago.to_date, 9.months.ago.to_date, 11.months.ago.to_date, (11.months+3.weeks).ago.to_date]
    User.find_old_accounts.each do |user|
      users << user if warning_dates.include?(user.last_logged_in_at.to_date)
    end
    users
  end
end

