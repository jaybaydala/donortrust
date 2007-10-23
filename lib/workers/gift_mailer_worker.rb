# Put your code that runs your task inside the do_work method it will be
# run automatically in a thread. You have access to all of your rails
# models.  You also get logger and results method inside of this class
# by default.
class GiftMailerWorker < BackgrounDRb::Worker::RailsBase
  
  def do_work(args)
    # This method is called in it's own new thread when you
    # call new worker. args is set to :args
    num_sent = 0
    logger.info "[#{Time.now.utc.to_s}] Checking for scheduled Gifts to Email"
    gifts = find_records
    gifts.each do |g|
      num_sent+=1
      g.send_gift_mail
    end
    logger.info "[#{Time.now.utc.to_s}] Scheduled Gift Emails Sent: #{num_sent}"
    exit # This is required when the job is done!
  end

  def find_records(send_at_time = Time.now.utc)
    Gift.find(:all, :conditions=>['sent_at is null AND send_at <= ?', send_at_time.to_s(:db)])
  end
end
GiftMailerWorker.register
