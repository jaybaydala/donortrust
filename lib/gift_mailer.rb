require 'openwfe/util/scheduler'
include OpenWFE

class GiftEmailer
  attr_accessor :scheduler, :interval, :job_id, :num_sent, :started_on, :is_running

  def initialize
    @scheduler = Scheduler.new
    @interval = '30m'
    @is_running = false
  end

  def run_once
    num_sent = 0
    gifts = find_records
    gifts.each do |g|
      num_sent+=1
      g.send_gift_mail
      #p g[:sent]
    end
    RAILS_DEFAULT_LOGGER.info "[#{Time.now.to_s}] Scheduled Gift Emails Sent: #{num_sent}" if RAILS_DEFAULT_LOGGER
    return num_sent
  end

  def start
    @started_on = Time.now
    @is_running = true
    @scheduler.start
    @job_id = @scheduler.schedule_every(@interval){ 
      RAILS_DEFAULT_LOGGER.info "[#{Time.now.to_s}] Checking for scheduled Gifts to Email" if RAILS_DEFAULT_LOGGER
      @num_sent += run_once() 
    }
    RAILS_DEFAULT_LOGGER.debug "[#{Time.now.to_s}] Gift Email scheduler starting up. Interval: #{@interval}. Job ID: #{@job_id}" if RAILS_DEFAULT_LOGGER
    @scheduler.join if ENV['RAILS_ENV'] != 'test'
  end

  def stop
    @scheduler.stop
    @is_running = false
  end

  def find_records(send_at_time = Time.now)
    return Gift.find(:all, :conditions=>['sent_at is null and send_at <= ?', send_at_time.to_s(:db)])
  end
end
