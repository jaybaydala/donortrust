# to consider for later...
# job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task :output"
# set :output, {:error => 'log/cron_error.log', :standard => 'log/cron.log'}

# Learn more: http://github.com/javan/whenever
# set :cron_log, "#{RAILS_ROOT}/log/cron.log"
set :output, 'log/cron.log'

# We're using some weird times in here just to keep from collisions.
# The server can probably handle multiple of these at a time, but it doesn't hurt to spread it out either

every 15.minutes do
  rake "scheduler:gift_mailer"
end

%w(42 22 2).each do |at|
  every 1.hour, :at => at.to_i  do
    rake "scheduler:session_cleaner"
  end
end

every 30.minutes do
  rake "thinking_sphinx:reindex", :output => 'log/cron_search.log'
end

every 1.month do
  runner 'Subscription.notify_impending_card_expirations'
  runner 'Geolocation.expire_cache'
end

every 1.day, :at => '3:50am' do
  rake "scheduler:process_stale_accounts"
end

every 1.day, :at => '6:50am' do
  rake "scheduler:account_reminder"
end

every 1.day, :at => '7:18am' do
  rake "scheduler:gift_reminder"
end

every 1.day, :at => '4:00am' do
  rake "subscriptions:process_daily"
end

# every January 4 @ 6:20am
every '20 6 4 1 *' do
  rake "subscriptions:yearly_upowered_receipts"
end
