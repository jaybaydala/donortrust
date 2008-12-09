Before do
  ProjectStatus.generate!(:name => "Active") unless ProjectStatus.active
  ProjectStatus.generate!(:name => "Completed") unless ProjectStatus.completed
  PlaceType.generate!(:name => "City") unless PlaceType.city
end

Given /^there are (\d+) featured projects$/ do |num|
  num = num.to_i
  @projects = (1..num).map{Project.generate!(:featured => true, :project_status => ProjectStatus.active)}
end
Then /^I should see the featured projects$/ do
  response.body.should have_tag("h2", /Featured Projects/i)
  @projects.each{|project| response.body.should have_tag("#featured-projects #projectInfo-#{project.id}") }
end
Then /^I should be able to give to those projects$/ do
  @projects.each{|project| response.body.should have_tag("#featured-projects #projectInfo-#{project.id} div.sidebar-give")}
end

Given /^there is a project$/ do
  @project = Project.generate!(:project_status => ProjectStatus.active)
end
Then /^I should see the project information$/ do
  response.body.should have_tag("h1#pagetitle", "#{@project.partner.name}: #{@project.name}")
end
Then /^I should see links to more information$/ do
  response.body.should have_tag("li.detail-tab#intended-li a", /Intended Outcome/i)
  response.body.should have_tag("li.detail-tab#project-li a", /Project Plan/i)
  response.body.should have_tag("li.detail-tab#measurable-li a", /Measurable Feedback/i)
  response.body.should have_tag("li.detail-tab#stories-li a", /Stories/i)
  response.body.should have_tag("li.detail-tab#photos-li a", /Photos/i)
  response.body.should have_tag("li.detail-tab#videos-li a", /Videos/i)
end
Then /^I should be able to give to the project$/ do
  response.body.should have_tag("div.project-sidebar-buttons img[title=Give]")
end
