Given /^the following projects$/ do |table|
  table.hashes.each do |hash|
    country = Place.find_by_name(hash["location"]) || Factory(:country, :name => hash["location"])
    active_partner_status_id = PartnerStatus.active.id || Factory(:partner_status, :name => 'Active').id
    partner = Partner.find_by_name(hash["partners"]) || Factory(:partner, :name => hash["partners"], :partner_status_id => active_partner_status_id)
    if hash["status"] == "active"
      public_project_status_id = ProjectStatus.active.id || Factory(:project_status_active).id
    else
      public_project_status_id = ProjectStatus.completed.id || Factory(:project_status_completed).id
    end
    project = Factory(:project, :name => hash["name"], :total_cost => hash["total_cost"], :project_status_id => public_project_status_id, :partner => partner, :country => country)
    hash["sectors"].split(',').each do |sector|
      project.sectors << Sector.find_or_create_by_name(sector.strip)
    end
    assert Project.current.include? project
  end
end

Given /^the project statuses are setup$/ do
  active = ProjectStatus.active.try(:id) || Factory(:project_status_active).id
  completed = ProjectStatus.completed.try(:id) || Factory(:project_status_completed).id
end

Given /^the project indexes are processed$/ do
  ThinkingSphinx::Test.index 'project_core', 'project_delta'
  sleep(0.25)
end

Then /^I should see (\d+) projects listed$/ do |count|
  page.should have_css('#project-search-summary', :text => "#{count} found")
end

Given /^I search with a deprecated total_cost param of "([^"]*)"$/ do |param|
  visit "/dt/projects?search%5Btotal_cost%5D=#{param}"
end

Then /^the project list should have "([^"]*)" before "([^"]*)"$/ do |before, after|
  project_before = Project.find_by_name(before)
  project_after = Project.find_by_name(after)
  page.body.should =~ /#{project_before.name}.*#{project_after.name}/m
end