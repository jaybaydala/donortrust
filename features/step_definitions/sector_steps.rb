Given /^a sector with projects$/ do
  @sector = Factory(:sector, :name => "Demo Sector", :description => "Sector description")
  @project = Factory(:project, :name => "Project 123")
  @project.sectors << @sector
  @project.save!
end

