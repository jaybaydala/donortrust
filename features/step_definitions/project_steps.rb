Given /^the following projects$/ do |table|
  table.hashes.each do |hash|
    country = Place.find_by_name(hash["location"]) || Factory(:country, :name => hash["location"])
    active_partner_status_id = PartnerStatus.active.id || Factory(:partner_status, :name => 'Active').id
    partner = Partner.find_by_name(hash["partners"]) || Factory(:partner, :name => hash["partners"], :partner_status_id => active_partner_status_id)
    public_project_status_id = ProjectStatus.active.id || Factory(:project_status_active).id
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
  page.has_css?(".project-module", :count => count)
end