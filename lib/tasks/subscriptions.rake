namespace :subscriptions do
  desc "Run all the subscriptions for today. Can also pass a parseable FORDATE environment variable"
  task :process_daily => :environment do
    puts "[#{Time.now.utc.to_s}] Processing daily subscriptions"
    date = defined?(FORDATE) ? Date.parse(FORDATE) : Date.today
    day_of_month = date.day
    day_of_month = (Time.days_in_month(date.month)..day_of_month) if Time.days_in_month(date.month) < day_of_month
    subscriptions = Subscription.all(:conditions => ["(end_date IS NULL OR end_date >= ?) AND schedule_date IN (?) AND created_at NOT LIKE ?", Time.now.beginning_of_day, day_of_month, "#{Date.today.to_s(:db)}%"])
    puts "[#{Time.now.utc.to_s}] #{subscriptions.size} subscriptions found to process.#{' Processing...' if subscriptions.size > 0}"
    good_subscriptions = subscriptions.select do |subscription|
      begin
        Subscription.transaction do
          subscription.process_payment
        end
        true
      rescue ActiveMerchant::Billing::Error => exception
        send_exception(subscription)
        # BadSubscriptionNotifier.deliver_exception_notification(exception, subscription)
      end
    end
    send_notification(good_subscriptions) # unless good_subscriptions.blank?
  end
  
  task :test_exception_email => :environment do
    send_exception(Subscription.last)
    puts "test exception email sent"
  end
  task :test_notification_email => :environment do
    send_notification(Subscription.all(:limit => 5))
    puts "test notification email sent"
  end
  
  def send_notification(subscriptions)
    subject = "[UEnd] #{subscriptions.size} Subscriptions were processed"
    body = ""
    body += subscriptions.map{|s| s.attributes.to_yaml }.join("\n")
    send_message(subject, body)
  end
  
  def send_exception(subscription)
    subject = "[UEnd] Subscription Processing Error"
    body = subscription.attributes.to_yaml
    send_message(subject, body)
  end

  def send_message(subject, body)
    require 'pony'
    smtp_config = ActionMailer::Base.smtp_settings
    smtp_options = {
      :host     => smtp_config[:address],
      :port     => smtp_config[:port] || 587,
      :user     => smtp_config[:user_name],
      :password => smtp_config[:password],
      :auth     => smtp_config[:authentication], # :plain, :login, :cram_md5, no auth by default
      :domain   => smtp_config[:domain], # the HELO domain provided by the client to the server
      :tls => true
    }
    # RAILS_DEFAULT_LOGGER.debug("SMTP options: #{smtp_options.inspect}")
    Pony.mail(:subject => subject, 
      :body => body, 
      :to   => "tim@tag.ca", 
      :from => "subscriptions@uend.org", 
      :via  => :smtp, 
      :smtp => smtp_options
    )
  end
end
