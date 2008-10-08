require File.dirname(__FILE__) + '/../spec_helper'

describe CampaignsMailer do
  def parse_email(email)
    TMail::Address.parse(email)
  end
  # campaign emails
  describe "campaign_approved" do
    before do
      @campaign = Campaign.generate!
      @mail = CampaignsMailer.create_campaign_approved(@campaign)
    end
    it "should set the recipient to the campaign creator email address" do
      @mail.to_addrs.should == [parse_email(@campaign.creator.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Campaign approved\"" do
      @mail.subject.should == "ChristmasFuture: Campaign approved"
    end
  end
  
  describe "campaign_declined" do
    before do
      @campaign = Campaign.generate!
      @mail = CampaignsMailer.create_campaign_declined(@campaign)
    end
    it "should set the recipient to the campaign creator email address" do
      @mail.to_addrs.should == [parse_email(@campaign.creator.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Campaign declined\"" do
      @mail.subject.should == "ChristmasFuture: Campaign declined"
    end
  end

  # team emails
  describe "team_approved" do
    before do
      @team = Team.generate!
      @campaign = @team.campaign
      @mail = CampaignsMailer.create_team_approved(@campaign, @team)
    end
    it "should set the recipient to the team leader email address" do
      @mail.to_addrs.should == [parse_email(@team.leader.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Team approved\"" do
      @mail.subject.should == "ChristmasFuture: Team approved"
    end
  end
  
  describe "team_declined" do
    before do
      @team = Team.generate!
      @campaign = @team.campaign
      @mail = CampaignsMailer.create_team_declined(@campaign, @team)
    end
    it "should set the recipient to the team leader email address" do
      @mail.to_addrs.should == [parse_email(@team.leader.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Team declined\"" do
      @mail.subject.should == "ChristmasFuture: Team declined"
    end
  end

  # participant emails
  describe "participant_approved" do
    before do
      @participant = Participant.generate!
      @team = @participant.team
      @campaign = @team.campaign
      @user = @participant.user
      @mail = CampaignsMailer.create_participant_approved(@campaign, @team, @participant)
    end
    it "should set the recipient to the participant email address" do
      # @mail.to_addrs.should == [parse_email(@user.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Participation approved\"" do
      @mail.subject.should == "ChristmasFuture: Participation approved"
    end
  end
  
  describe "participant_declined" do
    before do
      @participant = Participant.generate!
      @team = @participant.team
      @campaign = @team.campaign
      @user = @participant.user
      @participant = Participant.generate!(:team => @team, :campaign => @campaign)
      @mail = CampaignsMailer.create_participant_declined(@campaign, @team, @participant)
    end
    it "should set the recipient to the participant email address" do
      # @mail.to_addrs.should == [parse_email(@user.full_email_address)]
    end
    it "should set the subject to \"ChristmasFuture: Participation declined\"" do
      @mail.subject.should == "ChristmasFuture: Participation declined"
    end
  end
end