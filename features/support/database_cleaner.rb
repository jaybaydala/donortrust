Before do
puts "cleaning db"
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
