class GiftReminderWorker < BackgrounDRb::MetaWorker
  set_worker_name :gift_reminder_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def do_work(args = nil)
    num_sent = 0
    logger.info "[#{Time.now.utc.to_s}] Checking for Gifts to send reminders for"
    gifts = find_reminder_gifts
    gift_ids = []
    gifts.each do |g|
      num_sent+=1
      g.send_gift_reminder
      gift_ids << g.id
    end
    logger.info "[#{Time.now.utc.to_s}] Reminder Gift Emails Sent: #{num_sent} [#{gift_ids.join(', ')}]"
  end

  def find_reminder_gifts
    gifts = []
    Gift.find_unopened_gifts.each do |gift|
      gifts << gift if [7, 2, 1].include?(gift.expiry_in_days)
    end
    gifts
  end
end
