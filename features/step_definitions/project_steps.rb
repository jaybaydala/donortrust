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

Then /^I should not be able to visit the projects page for "([^"]*)"$/ do |project|
  assert_raise(ActiveRecord::RecordNotFound) { visit dt_project_path(Project.find_by_name(project)) }
end

Then /^I shouldn't be able to add the project "([^"]*)" as a gift$/ do |project|
  assert_raise(ActiveRecord::RecordNotFound) { visit new_dt_gift_path(:project_id => Project.find_by_name(project).id) }
end

Then /^I shouldn't be able to add the project "([^"]*)" as an investment$/ do |project|
  assert_raise(ActiveRecord::RecordNotFound) { visit new_dt_investment_path(:project_id => Project.find_by_name(project).id) }
end

Given /^the project indexes are processed$/ do
  ThinkingSphinx::Test.index 'project_core', 'project_delta'
  sleep(0.25)
end

Then /^I should see (\d+) projects listed$/ do |count|
  page.has_css?(".project-module", :count => count)
end

Given /^the project "([^"]*)" is not visible in (.*)$/ do |name, hide_from|
  p = Project.find_by_name(name)
  p.ca = false if ['Canada','CA'].include? hide_from
  p.us = false if ['United States','US', 'U.S.', 'the U.S.'].include? hide_from
  p.save!
end

Given /^I am visiting from (.*)$/ do |country|
  if ['United States','US', 'U.S.', 'the U.S.'].include? country
    class ActionController::Request
      def remote_ip
        GEO_IPS[:US]
      end
    end
  end
  if ['Canada','CA'].include? country
    class ActionController::Request
      def remote_ip
        GEO_IPS[:CA]
      end
    end
  end
end

Given /^I search with a deprecated total_cost param of "([^"]*)"$/ do |param|
  visit "/dt/projects?search%5Btotal_cost%5D=#{param}"
end
