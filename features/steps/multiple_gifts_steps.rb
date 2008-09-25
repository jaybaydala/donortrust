Given "that I'm any user" do
# do nothing
end

When /I visit "([^\"]+)"/ do |url|
  visits url
end

Then /I will see a link that states "([^\"]+)" that points at "([^\"]+)"/ do |text, href|
  response.should have_tag("a[href=#{href}]", text)
end
