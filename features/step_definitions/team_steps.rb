Then /^I should be a member of the team$/ do
  @team.users.should include(@user)
end

Given /^the campaign has (\d+) teams$/ do |num_teams|
  num_teams.to_i.times do |i|
    creator = Factory.create(:user)
    Participant.create(:campaign => @campaign, :user => creator)
    @team = Factory(:team, :campaign => @campaign, :user => creator)
  end
  @campaign.teams.reload
end

Given /^I am a member of one of the teams$/ do
  if !@team.campaign.users.reload.include?(@user)
    Participant.create(:campaign => @team.campaign, :user => @user)
    @team.campaign.users.reload
  end
  Factory(:team_membership, :team => @team, :user => @user)
end

Given /^I follow the team link$/ do
  @team = @campaign.teams.first
  steps %Q{
    And I follow "#{@team.name}"
  }
end

When /^I visit the iend campaign team page for the other team$/ do
  @team = @campaign.teams.last
  steps %Q{
    And I follow "#{@team.name}"
  }
end

Given /^each team has (\d+) members$/ do |num_members|
  Team.all.each do |team|
    num_members.to_i.times do |i|
      Factory(:team_membership, :team => team)
    end
  end
end