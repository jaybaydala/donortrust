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
    now = Time.now 
    gifts = find_records now
    for g in gifts
      num_sent+=1
      g.send_gift_mail
      #p g[:sent]
    end
    return num_sent
  end

  def start
    @started_on = Time.now
    @is_running = true
    @scheduler.start
    @job_id = @scheduler.schedule_every(@interval){ @num_sent += run_once() }
  end

  def stop
    @scheduler.stop
    @is_running = false
  end

  def find_records(send_at_time)
    return Gift.find(:all, :conditions=>['sent_at is null and send_at <= ?', send_at_time.to_s(:db)])
  end
end
