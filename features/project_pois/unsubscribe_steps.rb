Given /^I have a project poi with token (\d+)$/ do |token|
  @project = Factory(:project)
  @project_poi = Factory(:project_poi, :project => @project)
  @project_poi.update_attributes :token => token
end

Then /^the project poi with token (\d+) should be unsubscribed$/ do |token|
  ProjectPoi.find_by_token(token).unsubscribed.should == true
end
