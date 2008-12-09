# Commonly used webrat steps
# http://github.com/brynary/webrat

When /^I press "(.*)"$/ do |button|
  clicks_button(button)
end

When /^I follow "(.*)"$/ do |link|
  clicks_link(link)
end

When /^I fill in "(.*)" with "(.*)"$/ do |field, value|
  fills_in(field, :with => value) 
end

When /^I select "(.*)" from "(.*)"$/ do |value, field|
  selects(value, :from => field) 
end

When /^I check "(.*)"$/ do |field|
  checks(field) 
end

When /^I uncheck "(.*)"$/ do |field|
  unchecks(field) 
end

When /^I choose "(.*)"$/ do |field|
  chooses(field)
end

When /^I attach the file at "(.*)" to "(.*)" $/ do |path, field|
  attaches_file(field, path)
end

When /^I visit (.*)$/ do |page|
  visits case page
  when "the home page"
    "/"
  when "the projects page"
    dt_projects_path
  when "the project"
    dt_project_path(@project)
  else
    page
    # raise "Can't find mapping from \"#{page}\" to a path"
  end
end


When /^I go to \"(.*)\"$/ do |page|
  visits case page
  when "the home page"
    "/"
  else
    page
    # raise "Can't find mapping from \"#{page}\" to a path"
  end
end

Then /^I should see "(.*)"$/ do |text|
  text = Regexp.escape(text)
  response.body.should =~ /text/m
end

Then /^I should not see "(.*)"$/ do |text|
  response.body.should_not =~ /#{text}/m
end
