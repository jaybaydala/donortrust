require File.dirname(__FILE__) + '/../../test_helper'

# see user_transaction_test.rb for amount and user tests
context "FeaturedProject" do
  fixtures :projects, :featured_projects

  setup do
  end

  specify "should belong_to project" do
    fp = FeaturedProject.find(1)
    fp.project_id?.should.not.equal false
    fp.project.should.not.be.nil
  end

  specify "self.find_projects should return an array of projects" do
    FeaturedProject.find_projects().length.should.equal 2
  end

  specify "self.find_projects should accept options" do
    FeaturedProject.find_projects(:conditions => {:project_id => 1}).length.should.equal 1
    FeaturedProject.find_projects(:limit => 1).length.should.equal 1
  end
end
