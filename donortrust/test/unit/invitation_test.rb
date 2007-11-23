require File.dirname(__FILE__) + '/../test_helper'

context "Invitation" do
  include DtAuthenticatedTestHelper
  fixtures :invitations, :users, :groups, :memberships
  
  setup do
  end
  
  specify "should create an invitation" do
    lambda {
      invitation = create_invitation
      invitation.new_record?.should.be false
    }.should.change(Invitation, :count)
  end
  
  specify "should require user_id, group_id and to_email" do
    %w( user_id group_id to_email).each do |field|
      lambda {
        i = create_invitation(field.to_sym => nil)
        i.errors.on(field.to_sym).should.not.be.nil
      }.should.not.change(Invitation, :count)
    end
  end
  
  specify "should require an existing user" do
    lambda {
      i = create_invitation(:user_id => 99999)
      i.errors.on(:user_id).should.not.be.nil
    }.should.not.change(Invitation, :count)
  end

  specify "should require an existing group" do
    lambda {
      i = create_invitation(:group_id => 99999)
      i.errors.on(:group_id).should.not.be.nil
    }.should.not.change(Invitation, :count)
  end

  specify "user must be a member of a public group" do
    u = users(:tim) # tim is not a member
    lambda {
      i = create_invitation(:group_id => 1, :user_id => u.id)
      i.errors.on(:group_id).should.not.be.nil
    }.should.not.change(Invitation, :count)
    u = users(:aaron) # aaron is a member
    lambda {
      i = create_invitation(:group_id => 1, :user_id => u.id)
      i.errors.on(:group_id).should.be.nil
    }.should.change(Invitation, :count)
    u = users(:quentin) # quentin is the founder
    lambda {
      i = create_invitation(:group_id => 1, :user_id => u.id)
      i.errors.on(:group_id).should.be.nil
    }.should.change(Invitation, :count)
  end

  specify "user must be an admin of group if it's a private group" do
    u = users(:quentin)
    lambda {
      i = create_invitation(:group_id => 2, :user_id => u.id) # group_id is private
      i.errors.on(:group_id).should.not.be.nil
    }.should.not.change(Invitation, :count)
    u = users(:tim) # tim is the founder of group 2
    lambda {
      i = create_invitation(:group_id => 2, :user_id => u.id) # group_id is private
      i.errors.on(:group_id).should.be.nil
    }.should.change(Invitation, :count)
    u = users(:tim) # aaron is an admin of group 2
    lambda {
      i = create_invitation(:group_id => 2, :user_id => u.id) # group_id is private
      i.errors.on(:group_id).should.be.nil
    }.should.change(Invitation, :count)
  end

  private
  def create_invitation(options = {})
    Invitation.create({ :user_id => users(:quentin).id, :group_id => groups(:private), :to_email => 'tim@example.com', :to_name => 'timg', :message => 'join our group!' }.merge(options))
  end
end
