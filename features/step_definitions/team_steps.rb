Then /^I should be a member of the team$/ do
  @team.users.should include(@user)
end

Given /^the campaign has (\d+) teams$/ do |num_teams|
  num_teams.to_i.times do |i|
    @team = Factory(:team, :campaign => @campaign)
  end
  @campaign.teams.reload
end

Given /^I am a member of one of the teams$/ do
  Factory(:team_membership, :team => @team, :user => @user)
end