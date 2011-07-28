# Learn more: http://github.com/javan/whenever
# set :cron_log, "#{RAILS_ROOT}/log/cron.log"
set :output, File.expand_path("#{__FILE__}/../log/cron.log")

# We're using some weird times in here just to keep from collisions. 
# The server can probably handle multiple of these at a time, but it doesn't hurt to spread it out either

every 15.minutes do
  rake "--trace scheduler:gift_mailer"
end

%w(42 22 2).each do |at|
  every 1.hour, :at => at.to_i  do
    rake "-s scheduler:session_cleaner"
  end
end

every 5.minutes do
  rake "-s thinking_sphinx:index"
end

every 1.month do
  runner 'Subscription.notify_impending_card_expirations'
end

every 1.day, :at => '3:50am' do
  rake "--trace scheduler:process_stale_accounts"
end

every 1.day, :at => '6:50am' do
  rake "-s scheduler:account_reminder"
end

every 1.day, :at => '7:18am' do
  rake "-s scheduler:gift_reminder"
end

every 1.day, :at => '12:00am' do
  rake "-s subscriptions:process_daily"
end

