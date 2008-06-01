require File.dirname(__FILE__) + '/../test_helper'

context "Share" do
  fixtures :shares
  
  specify "should require an email" do
    lambda {
      t = create_share(:email => nil)
      t.errors.on(:email).should.not.be.nil
    }.should.not.change(Share, :count)
  end

  specify "should require a to_email" do
    lambda {
      t = create_share(:to_email => nil)
      t.errors.on(:to_email).should.not.be.nil
    }.should.not.change(Share, :count)
  end
  
  specify "should have a nil project_id if blank or 0 is passed" do
    t = create_share(:project_id => nil)
    t.errors.on(:project_id).should.be.nil
    t.project_id.should.be.nil
    t = create_share(:project_id => 0)
    t.errors.on(:project_id).should.be.nil
    t.project_id.should.be.nil
    t = create_share(:project_id => "")
    t.errors.on(:project_id).should.be.nil
    t.project_id.should.be.nil
  end

  private
  def create_share(options = {})
    Share.create({ :name => 'tim', :email => 'tim@example.com', :to_name => 'jay', :to_email => 'jay@example.com', :message => 'hi there', :project_id => 1, :e_card_id => 1 }.merge(options))
  end
end
