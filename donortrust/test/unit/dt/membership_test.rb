require File.dirname(__FILE__) + '/../../test_helper'

context "Membership class" do
  fixtures :memberships, :users, :groups

  setup do
    @membership = Membership.new
  end
  
  specify "Memberships table should be 'memberships'" do
    Membership.table_name.should.equal 'memberships'
  end

  specify "should respond to owner?" do
    @membership.should.respond_to 'owner?'
  end

  specify "should respond to admin?" do
    @membership.should.respond_to 'admin?'
  end

  specify "should respond to member?" do
    @membership.should.respond_to 'member?'
  end

  specify "should create a member" do
    Membership.should.differ(:count).by(1) {
      m = create_membership(:user_id => users(:tim).id, :group_id => 1)
    }
  end
  
  specify "should require user_id and group_id" do
    %w( user_id group_id ).each do |field|
      lambda {
        u = create_membership(field.to_sym => nil)
        u.errors.on(field.to_sym).should.not.be.nil
      }.should.not.change(Membership, :count)
    end
  end
  
  specify "if no membership_type is supplied, should default to Membership.member" do
    m = create_membership(:user_id => users(:tim).id, :group_id => 1, :membership_type => nil)
    m.membership_type.should.equal Membership.member
  end

  specify "if a bogus membership_type is supplied, should default to Membership.member" do
    m = create_membership(:user_id => users(:tim).id, :group_id => 1, :membership_type => 99)
    m.membership_type.should.equal Membership.member
    m.destroy
    m = create_membership(:user_id => users(:tim).id, :group_id => 1, :membership_type => -1)
    m.membership_type.should.equal Membership.member
  end
  
  def create_membership(options={})
    @membership = Membership.create({:user_id => 1, :group_id => 1, :membership_type => Membership.member}.merge(options))
  end
end 

context "Membership types" do
  fixtures :memberships
   
  setup do
    @m = Membership.new
  end
  
  specify "should know when it is a founder" do
    @m.membership_type = Membership.founder
    @m.founder?.should.be true
  end

  specify "should know when it is not an owner" do
    @m.membership_type = Membership.member
    @m.owner?.should.be false
    @m.membership_type = Membership.admin
    @m.owner?.should.be false
  end

  specify "should know when it is an admin" do
    @m.membership_type = Membership.admin
    @m.admin?.should.be true

    @m.membership_type = Membership.founder
    @m.admin?.should.be true
  end

  specify "should know when it is not an admin" do
    @m.membership_type = Membership.member
    @m.admin?.should.be false
  end

  specify "should know when it is a member" do
    @m.membership_type = Membership.member
    @m.member?.should.be true
    @m.membership_type = Membership.admin
    @m.member?.should.be true
    @m.membership_type = Membership.founder
    @m.member?.should.be true
  end

end 

# membership connects users and groups and can store roles
# groups has many users through memberships
# users has many groups through memberships
# http://railscasts.com/episodes/47
# Roles
# 1 - Member
# 2 - Admin
# 3 - Owner (only one or called in and got it added by support staff )

                         