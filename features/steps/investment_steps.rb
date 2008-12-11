Given /^I am on the new project investment page$/ do
  @project = Project.generate!
  get("/dt/investments/new", {:project_id => @project.id})
end

Given /^my cart has an investment of \$(\d+\.?\d*)$/ do |amount|
  @project = Project.generate!
  add_investment_to_cart(amount, @project.id)
end

Given /^I add an investment for \$([\d]+[\.]?[\d]?) to my cart$/ do |amount|
  @project = Project.generate!
  add_investment_to_cart(amount, @project.id)
end

When /^I choose the project$/ do
  chooses("investment_project_id_#{@project.id}")
end
