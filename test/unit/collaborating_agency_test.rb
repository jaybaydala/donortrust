require File.dirname(__FILE__) + '/../test_helper'

context "Collaborating Agency Tests " do
  fixtures :collaborating_agencies, :projects
 
   specify "should create a collaborating agency" do
      CollaboratingAgency.should.differ(:count).by(1) {create_collaborating_agency} 
    end
     
   specify "should require agency_name" do
    lambda {
      t = create_collaborating_agency(:agency_name => nil)
      t.errors.on(:agency_name).should.not.be.nil
      }.should.not.change(CollaboratingAgency, :count)
   end
   
   specify "should require responsibilities" do
    lambda {
      t = create_collaborating_agency(:responsibilities => nil)
      t.errors.on(:responsibilities).should.not.be.nil
      }.should.not.change(CollaboratingAgency, :count)
    end
    
  specify "should require project" do
    lambda {
      t = create_collaborating_agency(:project => nil)
      t.errors.on(:project).should.not.be.nil
    }.should.not.change(CollaboratingAgency, :count)
  end
   
  def create_collaborating_agency(options = {})
    CollaboratingAgency.create({ :project_id => 1, :agency_name => "Test Agency", :responsibilities => 'Test Responsibilities' }.merge(options))  
  end                                                          
end
