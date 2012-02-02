require File.dirname(__FILE__) + '/../spec_helper'

describe Investment do

  describe "Sector Investment" do
    before do
      @sector = Factory(:sector)
      @project = Factory(:project)
      @project.sectors << @sector
      @project.save!
    end

    it "should select a random project from a sector and set project_id if sector id is given" do
      investment = Factory.build(:investment, :project_id => nil, :sector_id => @sector.id)
      investment.save
      investment.project_id.should == @project.id
    end
  end

end

