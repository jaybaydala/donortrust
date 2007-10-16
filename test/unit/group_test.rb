require File.dirname(__FILE__) + '/../test_helper'

class BusAdmin::GroupTest < Test::Unit::TestCase
context "Groups" do
  fixtures :groups, :group_types, :places
    
    specify "should create a group" do
      Group.should.differ(:count).by(1) {create_group} 
    end     
 
    specify "should require name" do
      lambda {
        t = create_group(:name => nil)
        t.errors.on(:name).should.not.be.nil
      }.should.not.change(Group, :count)
    end
   
    specify "should require group_type_id" do
      lambda {
        t = create_group(:group_type_id => nil)
        t.errors.on(:group_type_id).should.not.be.nil
      }.should.not.change(Group, :count)
    end
    
    specify "should require private" do
      lambda {
        t = create_group(:private => nil)
        t.errors.on(:private).should.not.be.nil
      }.should.not.change(Group, :count)
    end
   
    def create_group(options = {})
      Group.create({ :name => 'Group Name', :description => 'My Description', :group_type_id => 1, :private => 1, :place_id => 1, :featured => 1 }.merge(options))  
    end                                                          
  end
end

