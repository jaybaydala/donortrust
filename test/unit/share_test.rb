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

  private
  def create_share(options = {})
    Share.create({ :name => 'tim', :email => 'tim@example.com', :to_name => 'jay', :to_email => 'jay@example.com', :message => 'hi there', :project_id => 1, :e_card_id => 1 }.merge(options))
  end
end
