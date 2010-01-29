namespace :subscriptions do
  desc "Run all the subscriptions for today. Can also pass a parseable FORDATE environment variable"
  task :process_daily => :environment do
    date = ENV['FORDATE'] ? Date.parse(ENV['FORDATE']) : Date.today
    puts "[#{Time.now.utc.to_s}] Processing daily subscriptions for #{date.to_s(:db)}"
    day_of_month = date.day
    day_of_month = (day_of_month..31) if day_of_month < 31 && day_of_month == Time.days_in_month(date.month)
    subscriptions = Subscription.all(:conditions => ["begin_date < ? && (end_date IS NULL OR end_date >= ?) AND schedule_date IN (?)", date, date, day_of_month])
    puts "[#{Time.now.utc.to_s}] #{subscriptions.size} subscriptions found to process.#{' Processing...' if subscriptions.size > 0}"
    good_subscriptions = subscriptions.select do |subscription|
      begin
        Subscription.transaction do
          subscription.process_payment
        end
        true
      rescue ActiveMerchant::Billing::Error => exception
        send_exception(subscription)
        false
      end
    end
    send_notification(good_subscriptions) # unless good_subscriptions.blank?
    puts "[#{Time.now.utc.to_s}] #{good_subscriptions.size} out of #{subscriptions.size} subscriptions were successfully processed." if subscriptions.size > 0
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
    smtp_options = {}
    smtp_options[:host]     = smtp_config[:address] if smtp_config[:address]
    smtp_options[:port]     = smtp_config[:port] if smtp_config[:port]
    smtp_options[:user]     = smtp_config[:user_name] if smtp_config[:user_name]
    smtp_options[:password] = smtp_config[:password] if smtp_config[:password]
    # :plain, :login, :cram_md5, no auth by default
    smtp_options[:auth]     = smtp_config[:authentication] if smtp_config[:authentication]
    # the HELO domain provided by the client to the server
    smtp_options[:domain]   = smtp_config[:domain] if smtp_config[:domain]
    smtp_options[:tls] = true unless Rails.env == "production"
    # RAILS_DEFAULT_LOGGER.debug("SMTP options: #{smtp_options.inspect}")
    Pony.mail(:subject => subject, 
      :body => body, 
      :to   => "info@uend.org,tim@tag.ca", 
      :from => "subscriptions@uend.org", 
      :via  => :smtp, 
      :smtp => smtp_options
    )
  end
end
