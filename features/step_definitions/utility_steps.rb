Given /^it is the date ([^$]+)$/ do |date|
  date = date.to_date
  Timecop.travel(date)
end