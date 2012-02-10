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
  @team ||= @campaign.teams.first
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
      u = Factory.create(:user)
      Participant.create(:campaign => team.campaign, :user => u)
      Factory(:team_membership, :team => team, :user => u)
    end
  end
end

Then /^I should see the team member name$/ do
  @team_member ||= TeamMember.last
  steps %Q{
    Then I should see "#{@team_member.user.name}"
  }
end

Then /^I should see the name of the team member I donated to$/ do
  name = CampaignDonation.last.participant.user.name

  steps %Q{
    Then I should see "#{name}"
  }
end

Then /^I should see a list of team members$/ do
  @team ||= Team.first
  @team.users.each do |u|
    steps %Q{
      Then I should see "#{u.name}"
    }
  end
end

Then /^I should see "([^"]*)" next to each team member$/ do |arg1|
  @team.users.each do |u|
    steps %Q{
      And I should see "#{u.name} #{arg1}"
    }
  end
end

When /^I follow "([^"]*)" next to the first team member$/ do |link_text|
  @team_member = @team.team_memberships.first

  with_scope("#team_member_list li#team_membership_#{@team_member.id}") do
    click_link "#{link_text}"
  end

end

Then /^I should see the team name$/ do
  @team ||= Team.first
  steps %Q{
    And I should see "#{@team.name}"
  }
end
