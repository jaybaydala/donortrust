Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

# Clean the slate for thinking-sphinx search features:

Before('@no-txn') do
  Given 'a clean slate'
end

After('@no-txn') do
  Given 'a clean slate'
end