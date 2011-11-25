Given /^there is a poverty sector "([^"]*)"$/ do |name|
  Sector.create!(:name => name)
end

Given /^there is an iend profile named "([^"]*)" from "([^"]*)" with poverty sector "([^"]*)"$/ do |name, location, sector|
  first, last = name.split(' ')
  user = Factory(:user, :first_name => first, :last_name => last, :province => location)
  user.sectors << Sector.find_by_name(sector)
  user.save
end

Given /^the iend profile "([^"]*)" has a public name$/ do |name|
  first, last = name.split(' ')
  user = User.find_by_first_name_and_last_name(first, last)
  user.iend_profile.name = true
  user.iend_profile.save
end

Given /^the iend profile indexes are processed$/ do
  ThinkingSphinx::Test.index 'iend_profile_core', 'iend_profile_delta'
  sleep(0.25)
end

Given /^a clean slate$/ do
  Object.subclasses_of(ActiveRecord::Base).each do |model|
    next unless model.table_exists?
    model.connection.execute "TRUNCATE TABLE `#{model.table_name}`"
  end
end

Given /^the iend profile "([^"]*)" has a public location$/ do |name|
  first, last = name.split(' ')
  user = User.find_by_first_name_and_last_name(first, last)
  user.iend_profile.location = true
  user.iend_profile.save
end

Given /^the iend profile "([^"]*)" has a public name and private sectors$/ do |name|
  first, last = name.split(' ')
  user = User.find_by_first_name_and_last_name(first, last)
  user.iend_profile.name = true
  user.iend_profile.preferred_poverty_sectors = false
  user.iend_profile.save
end



Given /^there is a project named "([^"]*)"$/ do |name|
  proj = Factory(:project, :name => name)
  proj.save
end

Given /^there is an iend profile named "([^"]*)" who has invested in "([^"]*)"$/ do |name, project|
  first, last = name.split(' ')
  user = Factory(:user, :first_name => first, :last_name => last)
  user.save
  proj = Project.find_by_name(project)
  inv = Factory(:investment, :project => proj)
  inv.user = user
  inv.save
end

Given /^I have searched iend profiles by the project "([^"]*)"$/ do |project|
  proj = Project.find_by_name(project)
  visit "/iend/users?project=#{proj.id}"
end

Given /^the iend profile "([^"]*)" chose not to list projects funded$/ do |name|
  first, last = name.split(' ')
  user = User.find_by_first_name_and_last_name(first, last)
  user.iend_profile.list_projects_funded = false
  user.iend_profile.save
end