Before do
puts "cleaning the DB"
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
