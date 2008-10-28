require File.dirname(__FILE__) + '/../test_helper'

context "Cause Tests " do
  fixtures :causes

  specify "should create a cause" do
    Cause.should.differ(:count).by(1) {create_cause} 
  end
     
  specify "should require name" do
    lambda {
      t = create_cause(:name => nil)
      t.errors.on(:name).should.not.be.nil
    }.should.not.change(Cause, :count)
  end
   
  specify "name should be unique" do
    @cause = create_cause()
    @cause.save
    @cause = create_cause()
    @cause.should.not.validate
  end   
    
  def create_cause(options = {})
    Cause.create({ :name => 'Cause Name', :description => 'Cause Description' }.merge(options))  
  end                                                          
end
