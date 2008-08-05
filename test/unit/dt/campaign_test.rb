require File.dirname(__FILE__) + '/../../test_helper'

context "Campaign" do
  
  fixtures :campaigns, :campaign_types, :users
  
  setup do
    @campaign = Campaign.find(:first)
    @campaign.campaign_type = CampaignType.find(:first)
    @campaign.creator = User.find(:first)
    @campaign.save
  end
  
  specify "Should not save without valid name" do
    @campaign.name = nil
    @campaign.should.not.validate
    @campaign.name = ""
    @campaign.should.not.validate
  end
  
  specify "Should not save with a string for a fundraising goal" do
    @campaign.fundraising_goal = "Some Value"
    @campaign.should.not.validate
  end
  
  specify "Start date should be before end date" do
    @campaign.start_date = "2008-06-05 19:59:44"
    @campaign.end_date = "2007-06-05 19:59:44"
    @campaign.should.not.validate
  end
  
  specify "Should have a valid description" do
    @campaign.description = ""
    @campaign.should.not.validate
    @campaign.description = nil
    @campaign.should.not.validate
  end
  
  specify "Should have a valid country" do
    @campaign.country = nil
    @campaign.should.not.validate
  end
  
  specify "Does not validate with invalid postal code in canada" do
    @campaign.country = "Canada"
    @campaign.postalcode = "E3B3RA"
    @campaign.should.not.validate
  end
  
  specify "Does validate with valid postal code in Canada" do
    @campaign.country = "Canada"
    @campaign.postalcode = "E3B3R1"
    @campaign.should.validate
  end
  
  specify "Should have a creator" do
    @campaign.creator = nil
    @campaign.should.not.validate
  end
  
  specify "Should have a type" do
    @campaign.campaign_type = nil
    @campaign.should.not.validate
  end

  specify "Should have province" do
    @campaign.province = nil
    @campaign.should.not.validate
  end
  
  specify "Should have a fund raising goal" do
    @campaign.fundraising_goal = nil
    @campaign.should.not.validate
  end
  
  specify "Should not validate for the improper canadian postal codes" do
    @campaign.country = "Canada"
    @campaign.province = 'Alberta'
    @campaign.should.not.validate
  end
  
  specify "Should validate for the improper canadian postal codes" do
    @campaign.country = "Canada"
    @campaign.province = 'New Brunswick'
    @campaign.postalcode = "E3B3R1"
    @campaign.should.validate
    @campaign.province = 'Alberta'
    @campaign.postalcode = "T2S2J8"
    @campaign.should.validate
  end
  
  specify "Should validate for valid zip code in the USA" do
    @campaign.country = "United States"
    @campaign.province = "Maine"
    @campaign.postalcode = "01234"
    @campaign.should.validate
  end
  
  specify "Should not validate for invalid zip code in the USA" do
    @campaign.country = "United States"
    @campaign.province = "Maine"
    @campaign.postalcode = "11234"
    @campaign.should.not.validate
  end
end
