namespace :subscriptions do
  desc "Run all the subscriptions for today. Can also pass a parseable FORDATE environment variable"
  task :process_daily => :environment do
    date = ENV['FORDATE'] ? Date.parse(ENV['FORDATE']) : Date.today
    puts "[#{Time.now.utc.to_s}] Processing daily subscriptions for #{date.to_s(:db)}"
    subscriptions = Subscription.for_date(date)
    puts "[#{Time.now.utc.to_s}] #{subscriptions.size} subscriptions found to process.#{' Processing...' if subscriptions.size > 0}"
    good_subscriptions = subscriptions.select do |subscription|
      begin
        subscription.process_payment
        true
      rescue ActiveMerchant::Billing::Error => exception
        send_exception(subscription, exception)
        false
      rescue Exception => exception
        # need to report an error!!!!!!!!!!!!!!!!!!!
        send_bad_exception(subscription, exception)
        false
      end
    end
    send_notification(good_subscriptions) # unless good_subscriptions.blank?
    puts "[#{Time.now.utc.to_s}] #{good_subscriptions.size} out of #{subscriptions.size} subscriptions were successfully processed." if subscriptions.size > 0
  end

  desc "create/send yearly u:powered tax receipts"
  task :yearly_upowered_receipts => :environment do
    puts "[#{Time.now.utc.to_s}] Creating yearly tax receipts for u:powered"
    year = ENV['FORYEAR'] ? ENV['FORYEAR'] : Date.today.year-1
    previously_delivered = 0
    tax_receipts = Subscription.all.map do |subscription|
      next unless subscription.user
      # this is because of a tax receipting mishap the first time around
      if year == 2011 && TaxReceipt.count(:conditions => ["user_id=? AND (created_at LIKE ? OR created_at LIKE ?)", subscription.user_id, "#{year+1}-01-04%", "#{year+1}-02-28%"]) > 0
        previously_delivered = previously_delivered + 1
        tax_receipt = subscription.user.tax_receipts.first(:conditions => ["created_at LIKE ?", "#{year+1}-01-04%"])
        # pass in the existing tax_receipt for updating
        tax_receipt = subscription.create_yearly_tax_receipt(year, tax_receipt)
        # manually send the tax_receipt since it only auto-delivers on create
        DonortrustMailer.deliver_tax_receipt(tax_receipt) unless tax_receipt.nil?
        tax_receipt
      else
        tax_receipt = subscription.create_yearly_tax_receipt(year)
      end
    end
    puts "[#{Time.now.utc.to_s}] #{tax_receipts.compact.size} out of #{Subscription.count} possible u:powered tax receipts sent, #{previously_delivered} were previously sent and were adjusted and resent"
  end

  task :test_exception_email => :environment do
    send_exception(Subscription.last, Exception.new("This is a test exception"))
    puts "test exception email sent"
  end
  task :test_notification_email => :environment do
    send_notification(Subscription.all(:limit => 5))
    puts "test notification email sent"
  end

  desc "Upgrade the subscriptions to the Frendo API"
  task :upgrade_to_frendo => :environment do
    FasterCSV.read(Rails.root.join('data', 'subscriptions-20121204.csv'), :headers => true).each do |row|
      # csv = FasterCSV.read(Rails.root.join('data', 'subscriptions-20121204.csv'), :headers => true)
      # row = csv[67]
      credit_card_info = row[4].split('-').last
      card_number = credit_card_info[0..-6]
      expiry_month = credit_card_info[-5, 2].to_i
      expiry_year = credit_card_info[-2, 2].to_i + 2000
      subscription = Subscription.find_by_id_and_frendo(row[0], false)
      if subscription
        # hold on to the iats customer code, just in case :)
        subscription.update_attribute(:iats_customer_code, subscription.customer_code) unless subscription.iats_customer_code?
        # sign up for frendo
        subscription.update_attributes({
          :customer_code => nil,
          :card_number => card_number,
          :expiry_month => expiry_month,
          :expiry_year => expiry_year,
          :frendo => true
        })
      end
    end
  end

  def send_notification(subscriptions)
    subject = "[UEnd] #{subscriptions.size} Subscriptions were processed"
    body = ""
    body += subscriptions.map{|s| s.attributes.to_yaml }.join("\n")
    send_message(subject, body)
  end

  def send_exception(subscription, exception)
    subject = "[UEnd] Subscription Processing Error"
    body = "#{exception.message}\n#{exception.backtrace}\n\n#{subscription.attributes.to_yaml}"
    send_message(subject, body)
  end

  def send_bad_exception(subscription, exception)
    subject = "[UEnd] BAD Subscription Processing Error"
    body = "#{exception.message}\n#{exception.backtrace}\n\n#{subscription.attributes.to_yaml}"
    send_message(subject, body)
  end

  def send_message(subject, body)
    return unless ActionMailer::Base.delivery_method == :smtp
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
      :to   => ["info@uend.org", "tim@tag.ca", "jay.baydala@uend.org"],
      :from => "subscriptions@uend.org",
      :via  => :smtp,
      :smtp => smtp_options
    )
  end
end
