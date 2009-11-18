namespace :subscriptions do
  desc "Run all the subscriptions for today. Can also pass a parseable FORDATE environment variable"
  task :process_daily => :environment do
    puts "[#{Time.now.utc.to_s}] Processing daily subscriptions"
    date = defined?(FORDATE) ? Date.parse(FORDATE) : Date.today
    day_of_month = date.day
    day_of_month = (Time.days_in_month(date.month)..day_of_month) if Time.days_in_month(date.month) < day_of_month
    subscriptions = Subscription.all(:conditions => ["(end_date IS NULL OR end_date >= ?) AND schedule_date IN (?)", Time.now.beginning_of_day, day_of_month])
    puts "[#{Time.now.utc.to_s}] #{subscriptions.size} subscriptions found to process. Processing..."
    subscriptions.each do |subscription|
      begin
        Subscription.transaction do
          subscription.process_payment
        end
      rescue ActiveMerchant::Billing::Error => exception
        BadSubscriptionNotifier.deliver_exception_notification(exception, subscription)
      end
    end
  end
end

require "action_mailer"
class BadSubscriptionNotifier < ActionMailer::Base
  @@sender_address = %(support@christmasfuture.com)
  cattr_accessor :sender_address

  @@exception_recipients = ["sysadmin@pivotib.com"] #, "info@christmasfuture.org"]
  cattr_accessor :exception_recipients

  @@email_prefix = "[SUBSCRIPTION ERROR] "
  cattr_accessor :email_prefix

  self.template_root = "#{File.dirname(__FILE__)}/../../app/views"

  def self.reloadable?() false end

  def exception_notification(exception, subscription, data={})
    content_type "text/plain"

    subject    "#{email_prefix} Subscription #{subscription.id}#process_payment (#{exception.class}) #{exception.message.inspect}"

    recipients exception_recipients
    from       sender_address
    
    sections = [subscription, subscription.user]
    body       data.merge({ :exception => exception,
                  :backtrace => sanitize_backtrace(exception.backtrace),
                  :rails_root => rails_root, :data => data,
                  :sections => sections })
  end
  
  private

    def sanitize_backtrace(trace)
      re = Regexp.new(/^#{Regexp.escape(rails_root)}/)
      trace.map { |line| Pathname.new(line.gsub(re, "[RAILS_ROOT]")).cleanpath.to_s }
    end

    def rails_root
      @rails_root ||= Pathname.new(RAILS_ROOT).cleanpath.to_s
    end
  
end
