# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class GiftReminderWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    num_sent = 0
    logger.info "[#{Time.now.utc.to_s}] Checking for Gifts to send reminders for"
    gifts = find_reminder_gifts
    gifts.each do |g|
      num_sent+=1
      g.send_gift_mail
    end
    logger.info "[#{Time.now.utc.to_s}] Scheduled Gift Emails Sent: #{num_sent}"
  end

  def find_reminder_gifts
    gifts = []
    Gift.find_unopened_gifts.each do |gift|
      gifts << gift if [7, 2, 1].include?(gift.expiry_in_days)
    end
    gifts
  end
end
GiftReminderWorker.register
