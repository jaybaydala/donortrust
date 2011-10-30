require File.dirname(__FILE__) + '/../spec_helper'

describe Team do
  before do
    @team = Factory:team
  end

  it { should belong_to(:user) }
  it { should have_many(:team_memberships) }

  it "should start empty" do
    @team.team_memberships.should == []
  end


end