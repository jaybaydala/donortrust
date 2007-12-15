require File.dirname(__FILE__) + '/../../test_helper'
require 'pp'

context "Project" do
  fixtures :projects, :places
  
  setup do
  end

  specify "The project should have a project name & description" do
    @project = Project.find(1)
    @project.name.should.not.be.nil
    @project.description.should.not.be.nil
  end

  specify "A project's community should be available through @project.community, etc." do
    @project = Project.find(1)
    @project.community_id
    @project.community_id?.should.be true
    @project.community.should.not.be.nil
  end

  specify "A project's nation should be available through @project.nation, etc." do
    @project = Project.find(1)
    @project.nation_id.should == 2 #uganda
    @project.nation_id?.should.be true
    @project.nation.should.not.be.nil
  end

  specify "should return community_projects_count as an int" do
    @project = Project.find(1)
    @project.community_project_count.should >= 0
  end
  
  specify "should return total_cost, dollars_spent, dollars_raised and current_need" do
    @project = Project.find(1)
    @project.total_cost.should.be > 0
    @project.dollars_spent.should.be >= 0
    @project.dollars_raised.should.be >= 0
    @project.current_need.should.equal @project.total_cost - @project.dollars_raised
  end
  
  specify "dollars_raised should equal the Investments in the project" do
    @project = Project.find(1)
    total = 0
    Investment.find(:all, :conditions => {:project_id => @project.id}).each do |investment|
      total = total + investment.amount
    end
    @project.dollars_raised.should.equal total
  end
  
  specify "public_groups should return an array of non-private groups" do
    @project = Project.find(1)
    @project.public_groups.class.should.be Array
  end
  
  specify "summarized_description should return a 50 word description" do
    @project = Project.find(1)
    @project.description = <<-DESC
      Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure.
      Ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut.
      Magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan.
      Ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis.
      Dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit.
    DESC
    @project.save
    @project.summarized_description.split().size.should.equal 50
  end

  specify "summarized_description should return a description of x words" do
    @project = Project.find(1)
    @project.description = <<-DESC
      Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure.
      Ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut.
      Magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan.
      Ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis.
      Dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit.
    DESC
    @project.save
    @project.summarized_description(100).split().size.should.equal 100
  end
end

context "Project Statuses" do
  fixtures :projects, :partners
  
  specify "Project.find_public should only return projects that are started (2) or completed (4)" do
    @project = Project.find_public(:all).size.should.equal 2
  end

  specify "Project.find_public should return a specific id" do
    @project = Project.find_public(2).id.should.equal 2
  end

  specify "Project.find_public should return nil if it's a non-public project" do
    begin
      @project = Project.find_public(1).should.raise ActiveRecord::RecordNotFound
    rescue
    end
  end

  specify "Project.find_public should only return a specific id with a conditions hash" do
    @project = Project.find_public(:all, :conditions => {:partner_id => 1}).size.should.equal 2
    @project = Project.find_public(:first, :conditions => {:partner_id => 1}, :order => :id).id.should.equal 2
  end

  specify "Project.find_public should only return a specific id with a conditions string" do
    @project = Project.find_public(:all, :conditions => "partner_id = 1").size.should.equal 2
    @project = Project.find_public(:first, :conditions => "partner_id = 1", :order => :id).id.should.equal 2
  end

  specify "Project.find_public should only return a specific id with a conditions array" do
    @project = Project.find_public(:all, :conditions => ["partner_id = ?", 1]).size.should.equal 2
    @project = Project.find_public(:first, :conditions => ["partner_id = ?", 1], :order => :id).id.should.equal 2
  end

  specify "Project.find_public should not return a project with a deleted partner_id" do
    Partner.find(partners(:one).id).destroy
    @project = Project.find_public(:first, :conditions => ["partner_id = ?", 1], :order => :id)
    @project.should.be.nil
  end
  
  specify "project.fundable? should return false if it's not a public project" do
    @project = Project.find_public(:first)
    @project.update_attributes(:project_status_id => 2)
    @project.fundable?.should.be true
    @project.update_attributes(:project_status_id => 4)
    @project.fundable?.should.be false
  end
  specify "project.fundable? should return false if current_need is 0" do
    @project = Project.find_public(:first)
    @project.update_attributes(:project_status_id => 2)
    @project.stubs(:current_need).returns(1)
    @project.fundable?.should.be true
    @project.stubs(:current_need).returns(0)
    @project.fundable?.should.be false
  end
end

context "Project Groups" do
  fixtures :projects, :users, :groups
  
  specify "project.group_project? should return true if a user is a member of a group which is also in the project's group list" do
    @user = users(:quentin)
    @user.memberships.clear
    @project = Project.find_public(:first)
    @project.groups.clear
    
    @group = Group.find(:first)
    @project.groups << @group
    @user.groups << @group
    
    @project.group_project?(@user).should.be true
  end

  specify "project.group_project? should return false if a user not is a member of a group which is also in the project's group list" do
    @user = users(:quentin)
    @user.memberships.clear
    @project = Project.find_public(:first)
    @project.groups.clear

    @group = Group.find(:first)
    @project.groups << @group

    @project.group_project?(@user).should.be false
    
    @user.groups << @group
    @project.group_project?(@user).should.be true
    
  end
end