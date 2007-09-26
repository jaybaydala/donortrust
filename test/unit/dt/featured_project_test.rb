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
end
