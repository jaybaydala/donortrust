class GiftMailer
  class << self
    def run
      num_sent = 0
      gifts = GiftMailer.find_records
      gifts.each do |g|
        num_sent+=1
        g.send_gift_mail
        #p g[:sent]
      end
      return num_sent
    end

    def find_records(send_at_time = Time.now)
      Gift.find(:all, :conditions=>['sent_at is null AND send_at <= ?', send_at_time.to_s(:db)])
    end
  end
end
