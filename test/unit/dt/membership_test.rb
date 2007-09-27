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
end 

context "Membership types" do
  fixtures :memberships
   
  setup do
    @m = Membership.new
  end
  
  specify "should know when it is an owner" do
    @m.membership_type = 3
    @m.owner?.should.be true
  end

  specify "should know when it is not an owner" do
    @m.membership_type = 1
    @m.owner?.should.be false
    @m.membership_type = 2
    @m.owner?.should.be false
  end

  specify "should know when it is an admin" do
    @m.membership_type = 2
    @m.admin?.should.be true

    @m.membership_type = 3
    @m.admin?.should.be true
  end

  specify "should know when it is not an admin" do
    @m.membership_type = 1
    @m.admin?.should.be false
  end

  specify "should know when it is a member" do
    @m.membership_type = 1
    @m.member?.should.be true
    @m.membership_type = 2
    @m.member?.should.be true
    @m.membership_type = 3
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

                         