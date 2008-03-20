class GiftMailerWorker < BackgrounDRb::MetaWorker
  set_worker_name :gift_mailer_worker
  def create(args = nil)
    # this method is called, when worker is loaded for the first time
  end

  def do_work(args = nil)
    num_sent = 0
    logger.info "[#{Time.now.utc.to_s}] Checking for scheduled Gifts to Email"
    gifts = find_records
    gift_ids = []
    gifts.each do |g|
      num_sent+=1
      g.send_gift_mail
      gift_ids << g.id
    end
    logger.info "[#{Time.now.utc.to_s}] Scheduled Gift Emails Sent: #{num_sent} [#{gift_ids.join(', ')}]"
  end

  def find_records(send_at_time = Time.now.utc)
    Gift.find(:all, :conditions=>['sent_at is null AND send_at <= ?', send_at_time.to_s(:db)])
  end
end
